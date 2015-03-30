package Twitter::API;
# Abstract: Twitter API library
our $VERSION = 0.01000;

use 5.12.1;
use Moo;
use strictures 2;
use namespace::autoclean;
use Carp;
use Class::Load qw/load_class/;
use JSON::MaybeXS qw/decode_json/;
use HTTP::Request::Common qw/GET POST/;
use HTTP::Thin;
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
        return {
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

        load_class 'HTTP::Tiny';
        HTTP::Thin->new(
            timeout => $self->timeout,
            agent   => $self->agent,
        );
    },
    handles => {
        send_request => 'request',
    },
);

sub BUILD {
    my ( $self, $args ) = @_;

    if ( my $traits = delete $$args{traits} ) {
        my @roles = map { s/^\+// ? $_ : "Twitter::API::Traits::$_" } @$traits;
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

    $self->preprocess_args($c);
    $self->preprocess_url($c);
    $self->add_authentication($c);
    my $req = $self->finalize_request($c);
    $self->send_request($c, $req);
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

    my $req;
    for ( $c->{http_method} ) {
        $req = $self->finalize_multipart_post($c)
            when $_ eq 'POST' && $self->is_multipart($c->{args});
        $req = $self->finalize_post($c)  when $_ eq 'POST';
        $req = $self->finalize_get($c)   when $_ eq 'GET';
        default { croak "unexpected HTTP method: $_" }
    }

    $req;
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
    my ( $orig, $self, $c, $req ) = @_;

    my $res = $self->$orig($req);
    $self->process_response($c, $res);
};

sub flatten_array_args {
    my ( $self, $args ) = @_;

    # transform arrays to comma delimited strings
    for my $k ( keys %$args ) {
        my $v = $$args{$k};
        $$args{$k} = join ',' => @$v if ref $v && reftype $v eq 'ARRAY';
    }
}

sub encode { URI::Escape::uri_escape_utf8($_[1],'^\w.~-') }

sub encode_args_string {
    my ( $self, $args ) = @_;

    my @pairs;
    for my $k ( sort keys %$args ) {
        push @pairs, join '=', map $self->encode($_), $k, $$args{$k};
    }

    return join '&', @pairs;
}

sub process_response {
    my ( $self, $c, $res ) = @_;

    my $data = try { decode_json($res->decoded_content) };

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
    return $msg;
}

sub add_authentication {
    my ( $self, $c ) = @_;

    my $args = $c->{args};
    my $req = Net::OAuth->request('protected resource')->new(
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        token            => $self->access_token,
        token_secret     => $self->access_token_secret,
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
