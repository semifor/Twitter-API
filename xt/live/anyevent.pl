#!/usr/bin/env perl
use 5.12.1;
use strictures 2;

use AnyEvent;
use Twitter::API::AnyEvent;

my $api = Twitter::API::AnyEvent->new(
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $cv = AE::cv;

$api->get('account/verify_credentials', sub {
    my ( $data, $c, $res, $msg ) = @_;

    $cv->croak($msg) unless $data;
    $cv->send($data);
});

my $r = $cv->recv;
say "$$r{screen_name} is authorized";

