#!/usr/bin/env perl
use 5.12.1;
use strictures 2;
use utf8;
use open qw/:std :utf8/;
use Test::More;

use Twitter::API;

my $api = Twitter::API->new(
    traits => [ qw/ApiMethods DecodeHtmlEntities/ ],
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $r = $api->show_status(801814387723935744);

diag $$r{text};
is $$r{text}, q{Test DecodeHtmlEntities trait. < & > ⚠️ 🏉 'single' "double"},
    'has no encoded HTML entities';

done_testing;
