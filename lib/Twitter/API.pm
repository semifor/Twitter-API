package Twitter::API;
# Abstract: Twitter API library
our $VERSION = 0.01000;

use Moo;
use strictures 2;
use namespace::autoclean;
use Carp;
use Class::Load qw/load_class/;
use JSON::MaybeXS qw/decode_json/;
use HTTP::Request;
use Net::OAuth;
use Digest::SHA;
use Try::Tiny;
use Scalar::Util qw/reftype/;
use URI;
use URI::Escape ();
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
        HTTP::Tiny->new(
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
    $self->add_headers($c);
    $self->add_authentication($c);
    $self->finalize_request($c);
    $self->send_request($c);
}

sub preprocess_args {
    my ( $self, $c ) = @_;

    $self->flatten_array_args($c->{args});
}

sub preprocess_url {
    my ( $self, $c ) = @_;

    my ( $url, $args ) = @{ $c }{qw/url args/};
    unless ( $url =~ m(^https?://) ) {
        $url =~ s/:(\w+)/delete $$args{$1}/eg;
        $c->{url} = join('/', $self->api_url, $url) . '.json';
    }
}

sub add_headers {
    my ( $self, $c ) = @_;

    if ( $c->{http_method} eq 'POST' ) {
        $c->{headers}{'Content-Type'} = 'application/x-www-form-urlencoded';
    }
}

sub finalize_request {
    my ( $self, $c ) = @_;

    my $uri = $c->{uri} = URI->new($c->{url});

    # TODO: unless multi-part request
    if ( my $encoded_args_string = $self->encode_args_string($c->{args}) ) {
        if ( $c->{http_method} eq 'POST' ) {
            $c->{body} = $encoded_args_string;
        }
        else {
            $uri->query($encoded_args_string);
        }
    }
}

around send_request => sub {
    my ( $orig, $self, $c ) = @_;

    my $res = $self->$orig($c->{http_method}, $c->{uri}, {
        headers => $c->{headers},
        content => $c->{body},
    });

    $c->{response} = $res;
    return $self->process_response($c, $res);
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
    my ( $self, $c ) = @_;

    my $res = $c->{response};
    my $data = try { decode_json($res->{content}) };

    if ( $data && $res->{success} ) {
        return wantarray ? ( $data, $c ) : $data;
    }

    return $self->process_error_response($c, $data);
}

sub process_error_response {
    my ( $self, $c, $data ) = @_;

    my $msg = $self->error_message($c, $data);
    Twitter::API::Error->throw({
        message       => $msg,
        context       => $c,
        twitter_error => $data,
    });
}

sub error_message {
    my ( $self, $c, $data ) = @_;

    my $res  = $c->{response};
    my $msg  = "$$res{status}: $$res{reason}";
    my $errors = try {
        join ', ' => map "$$_{code}: $$_{message}", @{ $$data{errors} };
    };

    $msg = join ' => ', $msg, $errors if $errors;
    return $msg;
}

sub add_authentication {
    my ( $self, $c ) = @_;

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
        extra_params     => $c->{args},
    );

    $req->sign;
    $c->{headers}{Authorization} =  $req->to_authorization_header;
}

1;
