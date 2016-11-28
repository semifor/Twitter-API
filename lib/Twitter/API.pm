package Twitter::API;
our $VERSION = '1.0000';

use 5.12.1;
use Moo;
use strictures 2;
use Carp;
use Class::Load qw/load_class/;
use JSON::MaybeXS ();
use HTTP::Request::Common qw/GET POST/;
use Net::OAuth;
use Digest::SHA;
use Try::Tiny;
use Scalar::Util qw/reftype/;
use URI;
use URL::Encode ();
use Encode qw/encode_utf8/;
use Twitter::API::Error;

use namespace::clean;

has [ qw/consumer_key consumer_secret/ ] => (
    is       => 'ro',
    required => 1,
);

has [ qw/access_token access_token_secret/ ] => (
    is        => 'rw',
    predicate => 1,
);

has api_url => (
    is      => 'ro',
    default => sub { 'https://api.twitter.com' },
);

has api_version => (
    is      => 'ro',
    default => sub { '1.1' },
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

has default_headers => (
    is => 'ro',
    default => sub {
        {
            accept                   => 'application/json',
            content_type             => 'application/json;charset=utf8',
            x_twitter_client         => 'Perl5-' . __PACKAGE__,
            x_twitter_client_version => $VERSION,
            x_twitter_client_url     => 'https://github.com/semifor/Twitter-API',
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
    handles => {
        from_json => 'decode',
        to_json   => 'encode',
    },
);

sub authorized { $_[0]->has_access_token && $_[0]->has_access_token_secret }

sub BUILD {
    my ( $self, $args ) = @_;

    if ( my $traits = delete $$args{traits} ) {
        for my $i ( 0..$#$traits ) {
            splice @$traits, $i, 1, qw/
                ApiMethods RetryOnError DecodeHtmlEntities NormalizeBooleans
                WrapResult
            / and last if $$traits[$i] eq '@enchilada';
        }
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
    $c->{http_response} = $self->send_request($c) // return;

    $self->inflate_response($c);
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
        $c->{url} = join('/', $self->api_url, $self->api_version, $url)
            . '.json';
    }
}

sub add_authorization {
    my ( $self, $c ) = @_;

    my $oauth_type = $$c{-oauth_type} // 'protected resource';
    my $oauth_args = $$c{-oauth_args } // {
        token        => $$c{-token} // $self->access_token,
        token_secret => $$c{-token_secret} // $self->access_token_secret,
    };
    my $args = $c->{args};
    my $req = Net::OAuth->request($oauth_type)->new(%$oauth_args,
        protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0A,
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        request_url      => $c->{url},
        request_method   => $c->{http_method},
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => Digest::SHA::sha1_base64({} . time . $$ . rand),
        extra_params     => $self->is_multipart($args) ? {} : $args,
    );

    $req->sign;
    $c->{headers}{authorization} =  $req->to_authorization_header;
}

sub finalize_request {
    my ( $self, $c ) = @_;

    # possible override Accept header
    $c->{headers}{accept} = $c->{-accept} if exists $c->{-accept};

    my $method = $c->{http_method};
    $c->{http_request} =
        $method eq 'POST' ? (
            $self->is_multipart($c->{args}) ? $self->finalize_multipart_post($c)
            : $c->{-to_json} ? $self->finalize_json_post($c)
            : $self->finalize_post($c)
        )
        : $method eq 'GET' ? $self->finalize_get($c)
        : croak "unexpected HTTP method: $_";
}

sub finalize_multipart_post {
    my ( $self, $c ) = @_;

    my $headers = $c->{headers};
    $headers->{content_type} = 'multipart/form-data;charset=utf-8';
    POST $c->{url},
        %$headers,
        Content => [
            map { ref $_ ? $_ : encode_utf8 $_ } %{ $c->{args} },
        ];
}

sub finalize_json_post {
    my ( $self, $c ) = @_;

    POST $c->{url},
        %{ $c->{headers} },
        Content => $self->to_json($c->{-to_json});
}

sub finalize_post {
    my ( $self, $c ) = @_;

    my $headers = $c->{headers};
    $headers->{content_type} = 'application/x-www-form-urlencoded;charset=utf-8';
    POST $c->{url},
        %$headers,
        Content => $self->encode_args_string($c->{args});
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

sub inflate_response {
    my ( $self, $c ) = @_;

    my $res = $c->{http_response};
    my $data;
    try {
        if ( $res->content_type eq 'application/json' ) {
            $data = $self->from_json($res->content);
        }
        elsif ( ($c->{-accept} // '') eq 'application/x-www-form-urlencoded' ) {

            # Twitter sets Content-Type: text/html for /oauth/request_token and
            # /oauth/access_token even though they return url encoded form
            # data. So we'll decode based on what we expected when we set the
            # Accept header. We don't want to assume form data when we didn't
            # request it, because sometimes twitter returns 200 OK with actual
            # HTML content. We don't want to decode and return that. It's an
            # error. We'll just leave $data unset if we don't have a reasonable
            # expectation of the content type.

            $data = URL::Encode::url_params_mixed($res->content, 1);
        }
    }
    catch {
        # Failed to decode the response body, synthesize an error response
        s/ at .* line \d+.*//s;  # remove file/line number
        $res->code(500);
        $res->status($_);
    };

    if ( $data && $res->is_success ) {
        return $data;
    }

    $self->process_error_response($c, $data);
}

sub flatten_array_args {
    my ( $self, $args ) = @_;

    # transform arrays to comma delimited strings
    for my $k ( keys %$args ) {
        my $v = $$args{$k};
        $$args{$k} = join ',' => @$v if ref $v && reftype $v eq 'ARRAY';
    }
}

sub encode_args_string {
    my ( $self, $args ) = @_;

    my @pairs;
    for my $k ( sort keys %$args ) {
        push @pairs, join '=', map $self->uri_escape($_), $k, $$args{$k};
    }

    join '&', @pairs;
}

sub uri_escape { URL::Encode::url_encode_utf8($_[1]) }

sub process_error_response {
    my ( $self, $c, $data ) = @_;

    my $msg = $self->error_message($c, $data);
    Twitter::API::Error->throw({
        message           => $msg,
        context           => $c,
        twitter_error     => $data,
    });
}

sub error_message {
    my ( $self, $c, $data ) = @_;

    my $res = $c->{http_response};
    my $msg  = join ': ', $res->code, $res->message;
    my $errors = try {
        join ', ' => map "$$_{code}: $$_{message}", @{ $$data{errors} };
    };

    $msg = join ' => ', $msg, $errors if $errors;
    $msg;
}

# If any of the args are references, we'll assume it's a multipart request
sub is_multipart { !!grep ref, values %{ $_[1] } }

# OAuth handshake

sub oauth_url_for {
    my ( $self, $endpoint ) = @_;

    join '/', $self->api_url, 'oauth', $endpoint;
}

sub get_request_token {
    my ( $self, $args ) = @_;

    $args->{callback} //= 'oob';
    return $self->request(post => $self->oauth_url_for('request_token'), {
        -accept     => 'application/x-www-form-urlencoded',
        -oauth_type => 'request token',
        -oauth_args => $args,
    });
}

my $auth_url = sub {
    my ( $self, $endpoint, $args ) = @_;

    my $uri = URI->new($self->oauth_url_for($endpoint));
    $uri->query_form($args);
    return $uri;
};

sub get_authentication_url { shift->$auth_url(authenticate => @_) }
sub get_authorization_url  { shift->$auth_url(authorize    => @_) }

sub get_access_token {
    my ( $self, $args ) = @_;

    $args->{-oauth_type} = 'access token';
    $self->request(post => $self->oauth_url_for('access_token'), {
        -accept     => 'application/x-www-form-urlencoded',
        -oauth_type => 'access token',
        -oauth_args => $args,
    });
}

sub xauth {
    my ( $self, $args ) = @_;

    my $username = delete $args->{username} // croak 'username required';
    my $password = delete $args->{password} // croak 'password required';
    if ( my $unexpected = join ', ' => keys %$args ) {
        croak "unexpected arguments: $unexpected";
    }

    $self->request(post => $self->oauth_url_for('access_token'), {
        -accept     => 'application/x-www-form-urlencoded',
        -oauth_type => 'XauthAccessToken',
        -oauth_args => {
            x_auth_mode     => 'client_auth',
            x_auth_password => $password,
            x_auth_username => $username,
        },
    });
}

# ABSTRACT: A Twitter REST API library for Perl

1;
