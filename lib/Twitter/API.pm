package Twitter::API;
our $VERSION = '0.0100';
use 5.14.1;
use Moo;
use Carp;
use Class::Load qw/load_class/;
use JSON::MaybeXS ();
use HTTP::Request::Common qw/GET POST/;
use Net::OAuth;
use Digest::SHA;
use Try::Tiny;
use URI;
use URL::Encode ();
use Encode qw/encode_utf8/;
use Twitter::API::Context;
use Twitter::API::Error;
use namespace::clean;

with 'MooX::Traits';
sub _trait_namespace { 'Twitter::API::Trait' }

has [ qw/consumer_key consumer_secret/ ] => (
    is       => 'ro',
    required => 1,
);

has [ qw/access_token access_token_secret/ ] => (
    is        => 'rw',
    predicate => 1,
    clearer   => 1,
);

# The secret is no good without the token.
after clear_access_token => sub {
    shift->clear_access_token_secret;
};

has api_url => (
    is      => 'ro',
    default => sub { 'https://api.twitter.com' },
);

has upload_url => (
    is      => 'ro',
    default => sub { 'https://upload.twitter.com' },
);

has api_version => (
    is      => 'ro',
    default => sub { '1.1' },
);

has agent => (
    is      => 'ro',
    default => sub {
        (join('/', __PACKAGE__, $VERSION) =~ s/::/-/gr) . ' (Perl)';
    },
);

has timeout => (
    is      => 'ro',
    default => sub { 10 },
);

has default_headers => (
    is => 'ro',
    default => sub {
        my $agent = shift->agent;
        {
            accept                   => 'application/json',
            content_type             => 'application/json;charset=utf8',
            user_agent               => $agent,
            x_twitter_client         => $agent,
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

sub get  { shift->request( get => @_ ) }
sub post { shift->request( post => @_ ) }

sub request {
    my $self = shift;

    my $c = Twitter::API::Context->new({
        http_method => uc shift,
        url         => shift,
        args        => shift || {},
        # shallow copy so we don't spoil the defaults
        headers     => { %{ $self->default_headers } },
        extra_args  => \@_,
    });

    $self->extract_synthetic_args($c);
    $self->preprocess_args($c);
    $self->preprocess_url($c);
    $self->add_authorization($c);
    $self->finalize_request($c);

    # Allow early exit for Twitter::API::AnyEvent
    $c->set_http_response($self->send_request($c) // return);

    $self->inflate_response($c);
    return wantarray ? ( $c->result, $c ) : $c->result;
}

sub extract_synthetic_args {
    my ( $self, $c ) = @_;

    my $args = $c->args;
    for ( keys %$args ) {
        $c->set_option($1, delete $$args{$_}) if /^-(.+)/;
    }
}

sub preprocess_args {
    my ( $self, $c ) = @_;

    if ( $c->http_method eq 'GET' ) {
        $self->flatten_array_args($c->args);
    }
}

sub preprocess_url {
    my ( $self, $c ) = @_;

    my $url = $c->url;
    my $args = $c->args;
    $url =~ s[:(\w+)][delete $$args{$1} // croak "missing arg $1"]eg;
    $c->set_url($self->api_url_for($url));
}

sub add_authorization {
    my ( $self, $c ) = @_;

    my $oauth_type = $c->get_option('oauth_type') // 'protected resource';
    my $oauth_args = $c->get_option('oauth_args') // {
        token        => $c->get_option('token') // $self->access_token,
        token_secret => $c->get_option('token_secret') // $self->access_token_secret,
    };
    my $args = $c->args;
    my $req = Net::OAuth->request($oauth_type)->new(%$oauth_args,
        protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0A,
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        request_url      => $c->url,
        request_method   => $c->http_method,
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => Digest::SHA::sha1_base64({} . time . $$ . rand),
        extra_params     => $self->is_multipart($args) ? {} : $args,
    );

    $req->sign;
    $c->set_header(authorization => $req->to_authorization_header);
}

sub finalize_request {
    my ( $self, $c ) = @_;

    # possible override Accept header
    $c->set_header(accept => $c->get_option('accept'))
        if $c->has_option('accept');

    my $method = $c->http_method;
    $c->set_http_request(
        $method eq 'POST' ? (
            $self->is_multipart($c->args) ? $self->finalize_multipart_post($c)
            : $c->has_option('to_json')   ? $self->finalize_json_post($c)
            : $self->finalize_post($c)
        )
        : $method eq 'GET' ? $self->finalize_get($c)
        : croak "unexpected HTTP method: $_"
    );
}

sub finalize_multipart_post {
    my ( $self, $c ) = @_;

    $c->set_header(content_type => 'multipart/form-data;charset=utf-8');
    POST $c->url,
        %{ $c->headers },
        Content => [
            map { ref $_ ? $_ : encode_utf8 $_ } %{ $c->args },
        ];
}

sub finalize_json_post {
    my ( $self, $c ) = @_;

    POST $c->url,
        %{ $c->headers },
        Content => $self->to_json($c->get_option('to_json'));
}

sub finalize_post {
    my ( $self, $c ) = @_;

    $c->set_header(
        content_type => 'application/x-www-form-urlencoded;charset=utf-8');
    POST $c->url,
        %{ $c->headers },
        Content => $self->encode_args_string($c->args);
}

sub finalize_get {
    my ( $self, $c ) = @_;

    my $uri = URI->new($c->url);
    if ( my $encoded = $self->encode_args_string($c->args) ) {
        $uri->query($encoded);
    }

    GET $uri, %{ $c->headers };
}

around send_request => sub {
    my ( $orig, $self, $c ) = @_;

    $self->$orig($c->http_request);
};

sub inflate_response {
    my ( $self, $c ) = @_;

    my $res = $c->http_response;
    my $data;
    try {
        if ( $res->content_type eq 'application/json' ) {
            $data = $self->from_json($res->content);
        }
        elsif ( $res->content_length == 0 ) {
            # E.g., 200 OK from media/metadata/create
            $data = '';
        }
        elsif ( ($c->get_option('accept') // '') eq 'application/x-www-form-urlencoded' ) {

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

    $c->set_result($data);
    return if defined($data) && $res->is_success;

    $self->process_error_response($c);
}

sub flatten_array_args {
    my ( $self, $args ) = @_;

    # transform arrays to comma delimited strings
    for my $k ( keys %$args ) {
        my $v = $$args{$k};
        $$args{$k} = join ',' => @$v if ref $v eq 'ARRAY';
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
    Twitter::API::Error->throw({ context => $_[1] });
}

# If any of the args are references, we'll assume it's a multipart request
sub is_multipart { !!grep ref, values %{ $_[1] } }

sub api_url_for {
    my $self = shift;

    $self->_url_for('.json', $self->api_url, $self->api_version, @_);
}

sub upload_url_for {
    my $self = shift;

    $self->_url_for('.json', $self->upload_url, $self->api_version, @_);
}

sub oauth_url_for {
    my $self = shift;

    $self->_url_for('', $self->api_url, 'oauth', @_);
}

sub _url_for {
    my ( $self, $ext, @parts ) = @_;

    # If we already have a fully qualified URL, just return it
    return $_[-1] if $_[-1] =~ m(^https?://);

    join('/', @parts) . $ext;
}

# OAuth handshake

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

__END__

=pod

=head1 SYNOPSIS

    ### Common usage ###

    use Twitter::API;
    my $api = Twitter::API->new_with_traits(
        traits              => 'Enchilada',
        consumer_key        => $YOUR_CONSUMER_KEY,
        consumer_secret     => $YOUR_CONSUMER_SECRET,
        access_token        => $YOUR_ACCESS_TOKEN
        access_token_secret => $YOUR_ACCESS_TOKEN_SECRET,
    );

    my $me   = $api->verify_credentials;
    my $user = $api->show_user('twitter');

    # In list context, both the Twitter API result and a Twitter::API::Context
    # object are returned.
    my ($r, $context) = $api->home_timeline({ count => 200, trim_user => 1 });
    my $remaning = $context->rate_limit_remaining;
    my $until    = $context->rate_limit_reset;


    ### No frills ###

    my $api = Twitter::API->new(
        consumer_key    => $YOUR_CONSUMER_KEY,
        consumer_secret => $YOUR_CONSUMER_SECRET,
    );

    my $r = $api->get('account/verify_credentials', {
        -token        => $an_access_token,
        -token_secret => $an_access_token_secret,
    });

    ### Error handling ###

    use Twitter::API::Util 'is_twitter_api_error';
    use Try::Tiny;

    try {
        my $r = $api->verify_credentials;
    }
    catch {
        die $_ unless is_twitter_api_error($_);

        # The error object includes plenty of information
        say $_->http_request->as_string;
        say $_->http_response->as_string;
        say 'No use retrying right away' if $_->is_permanent_error;
        if ( $_->is_token_error ) {
            say "There's something wrong with this token."
        }
        if ( $_->twitter_error_code == 326 ) {
            say "Oops! Twitter thinks you're spam bot!";
        }
    };

=head1 DESCRIPTION

Twitter::API provides an interface to the Twitter REST API for perl.

Features:

=for :list
* full support for all Twitter REST API endpoints
* optionally, specify access tokens per API call - no need to construct a new client fo to use different user credentials * error handling via an exception object that captures the full reqest/response context
* full support for OAuth handshake and xauth authentication

Additionl features are availble via optional traits:

=for :list
* convenient methods for API endpoints with simplified argument handling via L<ApiMethods|Twitter::API::Trait::ApiMethods>
* normalized booleans (Twitter likes 'true' and 'false', except when it doesn't) via L<NormalizeBooleans|Twitter::API::Trait::NormalizeBooleans>
* automatic decoding of HTML entities via L<DecodeHtmlEntities|Twitter::API::Trait::DecodeHtmlEntities>
* automatic retry on transient errors via L<RetryOnError|Twitter::API::Trait::RetryOnError>
* "the whole enchilada" combines all the above traits via L<Enchilada|Twitter::API::Trait::Enchilada>
* app-only (OAuth2) support via L<AppAuth|Twitter::API::Trait::AppAuth>

Some featuers are provided by separate distributions to avoid additional
dependencies most users won't want or need:

=for :list
* async support via subclass L<Twitter::API::AnyEvent>
* inflate API call results to objects via L<Twitter::API::Trait::InflateObjects>

=cut

=attr consumer_key, consumer_secret

Required. Every application has it's own application credentials.

=attr access_token, access_token_secret

Optional. If provided, every API call will be authenticated with these user
credentials. See L<AppAuth|Twitter::API::Trait::AppAuth> for app-only (OAuth2)
support, which does not require user credentials. You can also pass options
C<-token> and C<-token_secret> to specify user credentials on each API call.

=attr api_url

Optional. Defaults to C<https://api.twitter.com>.

=attr upload_url

Optional. Defaults to C<https://upload.twitter.com>.

=attr api_version

Optional. Defaults to C<1.1>.

=attr agent

Optional. Used for both the User-Agent and X-Twitter-Client identifiers.
Defaults to C<Twitter-API-$VERSION (Perl)>.

=attr timeout

Optional. Request timeout in seconds. Defaults to C<10>.

=method get($url, [ \%args ])

Issues an HTTP GET request to Twitter. If C<$url> is just a path part, e.g.,
C<account/verify_credentials>, it will be expanded to a full URL by prepending
the C<api_url>, C<api_version> and appending C<.json>. A full URL can also be
specified, e.g. C<https://api.twitter.com/1.1/account/verify_credentials.json>.

This should accommodate any new API endpoints Twitter adds without requiring an
update to this module.

=method put($url, [ \%args ])

See C<get> above, for a discussion C<$url>. For file upload, pass an array
reference as described in
L<https://metacpan.org/pod/distribution/HTTP-Message/lib/HTTP/Request/Common.pm#POST-url-Header-Value-...-Content-content>.

=method get_request_token([ \%args ])

This is the first step in the OAuth handshake. The only argument expected is
C<callback>, which defaults to C<oob> for PIN based verification. Web
applications will pass a callback URL.

Returns a hashref that includes C<oauth_token> and C<oauth_token_secret>.

See L<https://dev.twitter.com/oauth/reference/post/oauth/request_token>.

=method get_authentication_url(\%args)

This is the second step in the OAuth handshake. The only required argument is C<oauth_token>. Use the value returned by C<get_request_token>. Optional arguments: C<force_login> and C<screen_name> to prefill Twitter's authentication form.

See L<https://dev.twitter.com/oauth/reference/get/oauth/authenticate>.

=method get_authorization_url(\%args)

Identical to C<get_authentication_url>, but uses authorization flow, rather
than authentication flow.

See L<https://dev.twitter.com/oauth/reference/get/oauth/authorize>.

=method get_access_token(\%ags)

This is the third and final step in the OAuth handshake. Pass the request C<token>, request C<token_secret> obtained in the C<get_request_token> call, and either the PIN number if you used C<oob> for the callback value in C<get_request_token> or the C<verifier> parameter returned in the web callback, as C<verfier>.

See L<https://dev.twitter.com/oauth/reference/post/oauth/access_token>.

=method xauth(\%args)

Requires per application approval from Twitter. Pass C<username> and
C<password>.

=cut
