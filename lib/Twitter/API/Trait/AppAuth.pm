package Twitter::API::Trait::AppAuth;
# Abstract: Application-only (OAuth2) support for Twitter::API

use strictures 2;

use Moo::Role;
use Carp;
use HTTP::Request::Common qw/POST/;

sub request_token_url    () { 'https://api.twitter.com/oauth2/token' }
sub invalidate_token_url () { 'https://api.twitter.com/oauth2/invalidate_token' }

my $add_consumer_auth_header = sub {
    my ( $self, $req ) = @_;

    $req->headers->authorization_basic(
        $self->consumer_key, $self->consumer_secret);
};

sub request_access_token {
    my $self = shift;

    my $req = POST($self->request_token_url,
        'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
        Content        => { grant_type => 'client_credentials' },
    );
    $self->$add_consumer_auth_header($req);

    my $res = $self->simple_request($req);
    croak "request_token failed: ${ \$res->code }: ${ \$res->message }"
        unless $res->is_success;

    my $r = $self->from_json($res->decoded_content);
    croak "unexpected token type: $$r{token_type}" unless $$r{token_type} eq 'bearer';

    return $self->access_token($$r{access_token});
}

sub invalidate_token {
    my $self = shift;

    croak "no access_token" unless $self->authorized;

    my $req = POST($self->invalidate_token_url,
        'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
        Content        => join '=', access_token => $self->access_token,
    );
    $self->$add_consumer_auth_header($req);

    my $res = $self->simple_request($req);
    croak "invalidate_token failed: ${ \$res->code }: ${ \$res->message }"
        unless $res->is_success;

    $self->clear_access_token;
}

around add_authorization => sub {
    my $orig = shift;
    my ( $self, $c ) = @_;

    return unless $self->authorized;

    $c->{headers}{Authorization} = join ' ', Bearer => $self->access_token;
};

1;
