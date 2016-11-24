#!/usr/bin/env perl
use 5.12.1;
use strictures 2;
use utf8;
use open qw/:std :utf8/;

use Twitter::API;

my $api = Twitter::API->new(
    traits => [ qw/ApiMethods/ ],
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $r = $api->verify_credentials;
say "$$r{screen_name} is authorized";

my $mentions = $api->mentions({ user_id => $$r{id} });
for my $status ( @$mentions ) {
    say $$status{text};
}

