#!perl
use strict;
use warnings;

use HTTP::Response;
use Test::Fatal;
use Test::Spec;
use URL::Encode qw/url_params_mixed/;

use Twitter::API;

sub http_response_ok {
    HTTP::Response->new(
        200, 'OK',
        [
            content_type   => 'application/json;charset=utf-8',
            contest_length => 4,
        ],
        '{}'
    );
}

describe 'construction' => sub {

    it 'requires consumer_key' => sub {
       like(
            exception { Twitter::API->new },
            qr/Missing .* consumer_key/,
        );
    };

    it 'requires consumer_secret' => sub {
        like(
            exception { Twitter::API->new(consumer_key => 'key') },
            qr/Missing .* consumer_secret/,
        );
    };

    it 'instantiates a minimal object' => sub {
        exception {
            Twitter::API->new(
                consumer_key    => 'key',
                consumer_secret => 'secret',
            );
        }, undef;
    };
};

describe 'request' => sub {
    my $api;
    before each => sub {
        $api = Twitter::API->new(
            consumer_key    => 'key',
            consumer_secret => 'secret',
        );

        $api->stubs(send_request => \&http_response_ok);
    };

    it 'requires an access_token' => sub {
        like(
            exception { $api->request(get => 'fake/endpoint') },
            qr/token/,
        );
    };

    it 'accepts per request tokens' => sub {
        exception {
            $api->get('fake/endpoint', {
                -token        => 'my-token',
                -token_secret => 'my-secret',
            });
        }, undef;

    };

    it "uses object's user credentials" => sub {
        exception {
            $api->access_token('token');
            $api->access_token_secret('token-secret');
            $api->get('fake/endpoint');
        }, undef;
    };

    it 'prioritizes per-request user credentials' => sub {
        $api->access_token('token');
        $api->access_token_secret('token-secret');
        my ($r, $c) = $api->get('fake/endpoint', {
            -token        => 'per-request',
            -token_secret => 'per-request-secret',
        });
        my $req = $c->http_request;
        like $req->header('authorization'), qr/oauth_token="per-request"/;
    };
};

describe 'get' => sub {
    my $req;
    before each => sub {
        my $api = Twitter::API->new(
            consumer_key        => 'key',
            consumer_secret     => 'secret',
        );
        $api->stubs(send_request => \&http_response_ok);
        my ($r, $c) = $api->get('fake/endpoint', {
            -token        => 'token',
            -token_secret => 'access_token_secret',
            foo           => 'bar',
            baz           => 'bop',
        });
        $req = $c->http_request;
    };

    it 'uses method GET' => sub { is $req->method, 'GET' };
    it 'expands url' => sub {
        like $req->uri, qr{^\Qhttps://api.twitter.com/1.1/fake/endpoint.json};
    };
    it 'passes API arguments' => sub {
        is_deeply { $req->uri->query_form }, { foo => 'bar', baz => 'bop' };
    };
    it 'creates valid authorization header' => sub {
        like $req->header('authorization'), qr/
            OAuth\ oauth_consumer_key="key",
            oauth_nonce="[^"]+",
            oauth_signature="[^"]+",
            oauth_signature_method="HMAC-SHA1",
            oauth_timestamp="\d+",
            oauth_token="token",
            oauth_version="1\.0"
        /x;
    };

};

describe 'post' => sub {
    my $req;
    before each => sub {
        my $api = Twitter::API->new(
            consumer_key        => 'key',
            consumer_secret     => 'secret',
            access_token        => 'token',
            access_token_secret => 'secret',
        );
        $api->stubs(send_request => \&http_response_ok);
        my ($r, $c) = $api->post('fake/endpoint', {
            foo => 'bar',
            baz => 'bop',
        });
        $req = $c->http_request;
    };

    it 'has method POST' => sub { is $req->method, 'POST' };
    it 'has uses correct Contect-Type' => sub {
        is $req->content_type, 'application/x-www-form-urlencoded';
    };
    it 'passes API arguments' => sub {
        is_deeply url_params_mixed($req->decoded_content), {
            foo => 'bar',
            baz => 'bop',
        };
    };
};

describe 'post (file upload)' => sub {
    my $req;
    before each => sub {
        my $api = Twitter::API->new(
            consumer_key        => 'key',
            consumer_secret     => 'secret',
            access_token        => 'token',
            access_token_secret => 'secret',
        );
        $api->stubs(send_request => \&http_response_ok);
        my ($r, $c) = $api->post('fake/endpoint', {
            foo  => 'bar',
            baz  => 'bop',
            file => [ undef, 'file', content => 'just some text' ],
        });
        $req = $c->http_request;
    };

    it 'has correct content type' => sub {
        is $req->content_type, 'multipart/form-data';
    };
    it 'passes API args' => sub {
        my %args;
        for ( $req->parts ) {
            my ( $name ) = $_->header('content_disposition') =~ / name="([^"]+)"/;
            my $value = $_->decoded_content;
            $args{$name} = $value;
        }
        is_deeply \%args, {
            foo  => 'bar',
            baz  => 'bop',
            file => 'just some text',
        };
    };
};

describe 'post (json body)' => sub {
    my ( $api, $req );
    before each => sub {
        $api = Twitter::API->new(
            consumer_key        => 'key',
            consumer_secret     => 'secret',
            access_token        => 'token',
            access_token_secret => 'secret',
        );
        $api->stubs(send_request => \&http_response_ok);
        my ($r, $c) = $api->post('fake/endpoint', {
            -to_json => { foo => 'bar', baz => 'bop' },
        });
        $req = $c->http_request;
    };

    it 'has correct content type' => sub {
        is $req->content_type, 'application/json';
    };
    it 'has carrect content' => sub {
        my $json = $req->decoded_content;
        my $data = $api->from_json($json);
        is_deeply $data, { foo => 'bar', baz => 'bop' };
    };
};

runtests;
