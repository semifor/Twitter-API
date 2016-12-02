package Twitter::API::Trait::AppAuth;
# ABSTRACT: App-only (OAuth2) Authentication
$Twitter::API::Trait::AppAuth::VERSION = '0.0100'; # TRIAL
use Moo::Role;
use Carp;
use HTTP::Request::Common qw/POST/;
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

sub get_bearer_token {
    my $self = shift;

    $self->request(post => $self->oauth2_url_for('token'), {
        -add_consumer_auth_header => 1,
        grant_type => 'client_credentials',
    });
}

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

    $c->set_header(authorization => join ' ', Bearer => $token);
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

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::AppAuth - App-only (OAuth2) Authentication

=head1 VERSION

version 0.0100

=head1 SYNOPSIS

    use Twitter::API;
    my $client = Twitter::API->new_with_traits(
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

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
