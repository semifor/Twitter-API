#!/usr/bin/env perl
use 5.12.1;
use warnings;
use utf8;
use open qw/:std :utf8/;

use Twitter::API;

my $api = Twitter::API->new_with_traits(
    traits => [ qw/AppAuth ApiMethods/ ],
    consumer_key    => $ENV{CONSUMER_KEY},
    consumer_secret => $ENV{CONSUMER_SECRET},
);

my $token = $api->get_bearer_token;
$api->access_token($$token{access_token});
my $r = $api->user_timeline(twitterapi => { count => 10 });

for my $status ( @$r ) {
    say "$status->{user}{screen_name}: $status->{text}";
}

