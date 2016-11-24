#!/usr/bin/env perl
use 5.12.1;
use strictures 2;
use utf8;
use open qw/:std :utf8/;

use Twitter::API;

my $api = Twitter::API->new(
    traits => [ qw/ApiMethods InflateObjects WrapResult/ ],
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $r = $api->verify_credentials;
say "${ \$r->result->screen_name } is authorized";
say "Rate limit: ${ \$r->rate_limit }, remaining: ${ \$r->rate_limit_remaining }";

