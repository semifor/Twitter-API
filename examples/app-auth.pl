#!/usr/bin/env perl
use 5.12.1;
use strictures 2;
use utf8;
use open qw/:std :utf8/;

use Twitter::API;

my $api = Twitter::API->new(
    traits => [ qw/AppAuth ApiMethods/ ],
    consumer_key    => $ENV{CONSUMER_KEY},
    consumer_secret => $ENV{CONSUMER_SECRET},
);

$api->request_access_token;
my $r = $api->user_timeline(twitterapi => { count => 10 });

for my $status ( @$r ) {
    say "$status->{user}{screen_name}: $status->{text}";
}

