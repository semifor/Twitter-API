package Twitter::API;
# Abstract: Twitter API library
our $VERSION = 0.01000;

use 5.12.1;
use Moo;
use strictures 2;
use namespace::autoclean;
use Carp;
use Class::Load qw/load_class/;
use JSON::MaybeXS ();
use HTTP::Request::Common qw/GET POST/;
use Net::OAuth;
use Digest::SHA;
use Try::Tiny;
use Scalar::Util qw/reftype/;
use URI;
use URI::Escape ();
use Encode qw/encode_utf8/;
use Twitter::API::Error;

has [ qw/consumer_key consumer_secret/ ] => (
    is       => 'ro',
    required => 1,
);

has api_url => (
    is      => 'ro',
    default => sub { 'https://api.twitter.com/1.1' },
);

has agent => (
    is      => 'ro',
    default => sub {
        join('/', __PACKAGE__, $VERSION) =~ s/::/-/gr;
    },
);

has timeout => (
    is      => 'ro',
    default => sub { 10 },
);

has [ qw/access_token access_token_secret/ ] => (
    is        => 'rw',
    predicate => 1,
);

has default_headers => (
    is => 'ro',
    default => sub {
        {
            'X-Twitter-Client'         => 'Perl5-' . __PACKAGE__,
            'X-Twitter-Client-Version' => $VERSION,
            'X-Twitter-Client-URL'     => 'https://github.com/semifor/Twitter-API',
        };
    },
);

has user_agent => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;

        load_class 'HTTP::Thin';
        HTTP::Thin->new(
            timeout => $self->timeout,
            agent   => $self->agent,
        );
    },
    handles => {
        send_request   => 'request',
        simple_request => 'request',
    },
);

has json_parser => (
    is      => 'ro',
    lazy    => 1,
    default => sub { JSON::MaybeXS->new(utf8 => 1) },
    handles => { from_json => 'decode' },
);

sub authorized { shift->has_access_token }

sub BUILD {
    my ( $self, $args ) = @_;

    if ( my $traits = delete $$args{traits} ) {
        my @roles = map { s/^\+// ? $_ : "Twitter::API::Trait::$_" } @$traits;
        Role::Tiny->apply_roles_to_object($self, @roles);
    }
}

sub get  { shift->request( get => @_ ) }
sub post { shift->request( post => @_ ) }

sub request {
    my $self = shift;

    my $c = {
        http_method => uc shift,
        url         => shift,
        args        => shift || {},
        # shallow copy so we don't spoil the defaults
        headers     => { %{ $self->default_headers } },
        extra_args  => \@_,
    };

    $self->extract_synthetic_args($c);
    $self->preprocess_args($c);
    $self->preprocess_url($c);
    $self->add_authorization($c);
    $self->finalize_request($c);
    my $res = $self->send_request($c) // return;
    $self->inflate_response($c, $res);
}

sub extract_synthetic_args {
    my ( $self, $c ) = @_;

    my $args = $$c{args};
    for ( keys %$args ) {
        $$c{$_} = delete $$args{$_} if /^-/;
    }
}

sub preprocess_args {
    my ( $self, $c ) = @_;

    if ( $c->{http_method} eq 'GET' ) {
        $self->flatten_array_args($c->{args});
    }
}

sub preprocess_url {
    my ( $self, $c ) = @_;

    my ( $url, $args ) = @{ $c }{qw/url args/};
    unless ( $url =~ m(^https?://) ) {
        $url =~ s/:(\w+)/delete $$args{$1}/eg;
        $c->{url} = join('/', $self->api_url, $url) . '.json';
    }
}

sub finalize_request {
    my ( $self, $c ) = @_;

    my $method = $c->{http_method};
    $c->{http_request} =
        $method eq 'POST' ? (
            $self->is_multipart($c->{args}) ? $self->finalize_multipart_post($c)
            : $self->finalize_post($c)
        )
        : $method eq 'GET' ? $self->finalize_get($c)
        : croak "unexpected HTTP method: $_";
}

sub finalize_multipart_post {
    my ( $self, $c ) = @_;

    POST $c->{url},
        %{ $c->{headers} },
        Content_Type => 'form-data',
        Content      => [
            map { ref $_ ? $_ : encode_utf8 $_ } %{ $c->{args} },
        ];
}

sub finalize_post {
    my ( $self, $c ) = @_;

    POST $c->{url},
        %{ $c->{headers} },
        Content_Type => 'application/x-www-form-urlencoded',
        Content      => $self->encode_args_string($c->{args});
}

sub finalize_get {
    my ( $self, $c ) = @_;

    my $uri = URI->new($c->{url});
    if ( my $encoded = $self->encode_args_string($c->{args}) ) {
        $uri->query($encoded);
    }

    GET $uri, %{ $c->{headers} };
}

around send_request => sub {
    my ( $orig, $self, $c ) = @_;

    $self->$orig($c->{http_request});
};

sub flatten_array_args {
    my ( $self, $args ) = @_;

    # transform arrays to comma delimited strings
    for my $k ( keys %$args ) {
        my $v = $$args{$k};
        $$args{$k} = join ',' => @$v if ref $v && reftype $v eq 'ARRAY';
    }
}

sub uri_escape { URI::Escape::uri_escape_utf8($_[1],'^\w.~-') }

sub encode_args_string {
    my ( $self, $args ) = @_;

    my @pairs;
    for my $k ( sort keys %$args ) {
        push @pairs, join '=', map $self->uri_escape($_), $k, $$args{$k};
    }

    join '&', @pairs;
}

sub inflate_response {
    my ( $self, $c, $res ) = @_;

    my $data = try { $self->from_json($res->decoded_content) };

    if ( $data && $res->is_success ) {
        return $data;
    }

    $self->process_error_response($c, $res, $data);
}

sub process_error_response {
    my ( $self, $c, $res, $data ) = @_;

    my $msg = $self->error_message($c, $res, $data);
    Twitter::API::Error->throw({
        message       => $msg,
        context       => $c,
        response      => $res,
        twitter_error => $data,
    });
}

sub error_message {
    my ( $self, $c, $res, $data ) = @_;

    my $msg  = join ': ', $res->code, $res->message;
    my $errors = try {
        join ', ' => map "$$_{code}: $$_{message}", @{ $$data{errors} };
    };

    $msg = join ' => ', $msg, $errors if $errors;
    $msg;
}

sub add_authorization {
    my ( $self, $c ) = @_;

    my $args = $c->{args};
    my $req = Net::OAuth->request('protected resource')->new(
        protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0A,
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        token            => $$c{-access_token} // $self->access_token,
        token_secret     => $$c{-access_token_secret} // $self->access_token_secret,
        request_url      => $c->{url},
        request_method   => $c->{http_method},
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => Digest::SHA::sha1_base64({} . time . $$ . rand),
        extra_params     => $self->is_multipart($args) ? {} : $args,
    );

    $req->sign;
    $c->{headers}{Authorization} =  $req->to_authorization_header;
}

# If any of the args are references, we'll assume it's a multipart request
sub is_multipart { !!grep ref, values %{ $_[1] } }

1;
