#!/usr/bin/env perl
use 5.12.1;
use strictures 2;

use Twitter::API;

my $api = Twitter::API->new(
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $r = $api->get('account/verify_credentials');
say "$$r{screen_name} is authorized";

