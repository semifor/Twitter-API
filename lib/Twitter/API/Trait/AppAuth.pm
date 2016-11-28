package Twitter::API::Trait::AppAuth;
# Abstract: App-only (OAuth2) trait for Twitter::API

use strictures 2;

use Moo::Role;
use Carp;
use HTTP::Request::Common qw/POST/;
use namespace::clean;

# private methods

my $oauth2_url_for = sub { join '/', $_[0]->api_url, 'oauth2', $_[1] };

my $add_consumer_auth_header = sub {
    my ( $self, $req ) = @_;

    $req->headers->authorization_basic(
        $self->consumer_key, $self->consumer_secret);
};

# public methods

sub get_bearer_token {
    my $self = shift;

    $self->request(post => $self->$oauth2_url_for('token'), {
        -add_consumer_auth_header => 1,
        grant_type => 'client_credentials',
    });
}

sub invalidate_token {
    my ( $self, $token ) = @_;

    $self->request(post =>$self->$oauth2_url_for('invalidate_token'), {
        -add_consumer_auth_header => 1,
        -accept                   => '*/*',
        access_token              => $token,
    });
}

# request chain modifiers

around add_authorization => sub {
    my $orig = shift;
    my ( $self, $c ) = @_;

    # We do this in finalize_request after we have an HTTP::Request
    return if $$c{-add_consumer_auth_header};

    if ( $$c{-add_consumer_auth_header} ) {
        $self->$add_consumer_auth_header($$c{http_request});
        return;
    }

    my $token = $$c{-token} // $self->access_token // return;

    $c->{headers}{authorization} = join ' ', Bearer => $token;
};

around finalize_request => sub {
    my ( $next, $self, $c ) = @_;

    $self->$next($c);
    return unless $$c{-add_consumer_auth_header};

    $self->$add_consumer_auth_header($$c{http_request});
};

1;

__END__

=pod

=head1 SYNOPSIS

    use Twitter::API;
    my $api = Twitter::API->new(traits => [ qw/ApiMethods AppAuth/ ]);

    my $r = $api->get_bearer_token;
    # return value is hash ref:
    # { token_type => 'bearer', access_token => 'AA...' }
    my $token = $r->{access_token};

    # you can use the token explicitly with the -token argument:
    my $user = $api->show_user('twitter_api', { -token => $token });

    # or you can set the access_token attribute to use it implicitly
    $api->access_token($token);
    my $user = $api->show_user('twitterapi');

    # to revoke a token
    $api->invalidate_token($token);

    # if you revoke the token stored in the access_token attribute, clear it:
    $api->clear_access_token;

=cut
