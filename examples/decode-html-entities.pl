#!/usr/bin/env perl
use 5.12.1;
use strictures 2;
use utf8;
use open qw/:std :utf8/;

use Twitter::API;

my $api = Twitter::API->new(
    traits => [ qw/ApiMethods DecodeHtmlEntities WrapResult/ ],
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $r = $api->sent_direct_messages->result;
say "$$_{recipient_screen_name}: $$_{text}" for @$r;
