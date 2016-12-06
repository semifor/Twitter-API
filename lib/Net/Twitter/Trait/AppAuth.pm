package Net::Twitter::Trait::AppAuth;
# ABSTRACT: App-only (OAuth2) Authentication

use Moo::Role;
use Carp;
use HTTP::Request::Common qw/POST/;
use URL::Encode qw/url_encode url_decode/;
use namespace::clean;

# private methods

sub oauth2_url_for {
    my $self = shift;

    $self->_url_for('', $self->api_url, 'oauth2', @_);
}

my $add_consumer_auth_header = sub {
    my ( $self, $req ) = @_;

    $req->headers->authorization_basic(
        $self->consumer_key, $self->consumer_secret);
};

# public methods

=method get_bearer_token

Call the C<oauth2/token> endpoint to get a bearer token. The token is not
stored in Net::Twitter's state. If you want that, set the C<access_token>
attribute with the returned token.

See L<https://dev.twitter.com/oauth/reference/post/oauth2/token> for details.

=cut

sub get_bearer_token {
    my $self = shift;

    my $r = $self->request(post => $self->oauth2_url_for('token'), {
        -add_consumer_auth_header => 1,
        grant_type => 'client_credentials',
    });

    # In their wisdom, Twitter sends us a URL encoded token. We need to decode
    # it, so if/when we call invalidate_token, and properly URL encode our
    # parameters, we don't end up with a double-encoded token.
    return url_decode($$r{access_token});
}

=method invalidate_token($token)

Calls the C<oauth2/invalidate_token> endpoint to revoke a token. See
L<https://dev.twitter.com/oauth/reference/post/oauth2/invalidate/token> for
details.

=cut

sub invalidate_token {
    my ( $self, $token ) = @_;

    $self->request(post =>$self->oauth2_url_for('invalidate_token'), {
        -add_consumer_auth_header => 1,
        access_token              => $token,
    });
}

# request chain modifiers

around add_authorization => sub {
    my $orig = shift;
    my ( $self, $c ) = @_;

    # We do this in finalize_request after we have an HTTP::Request
    return if $c->get_option('add_consumer_auth_header');

    my $token = $c->get_option('token') // $self->access_token // return;

    $c->set_header(authorization => join ' ', Bearer => url_encode($token));
};

around finalize_request => sub {
    my ( $next, $self, $c ) = @_;

    $self->$next($c);
    return unless $c->get_option('add_consumer_auth_header');

    $self->$add_consumer_auth_header($c->http_request);
};

1;

__END__

=pod

=head1 SYNOPSIS

    use Net::Twitter;
    my $client = Net::Twitter->new_with_traits(
        traits => [ qw/ApiMethods AppAuth/ ]);

    my $r = $client->get_bearer_token;
    # return value is hash ref:
    # { token_type => 'bearer', access_token => 'AA...' }
    my $token = $r->{access_token};

    # you can use the token explicitly with the -token argument:
    my $user = $client->show_user('twitter_api', { -token => $token });

    # or you can set the access_token attribute to use it implicitly
    $client->access_token($token);
    my $user = $client->show_user('twitterapi');

    # to revoke a token
    $client->invalidate_token($token);

    # if you revoke the token stored in the access_token attribute, clear it:
    $client->clear_access_token;

=cut
