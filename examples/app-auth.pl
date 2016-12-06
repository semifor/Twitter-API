#!/usr/bin/env perl
use 5.14.1;
use warnings;
use utf8;
use open qw/:std :utf8/;

use Net::Twitter;

my $client = Net::Twitter->new_with_traits(
    traits => [ qw/AppAuth ApiMethods/ ],
    consumer_key    => $ENV{CONSUMER_KEY},
    consumer_secret => $ENV{CONSUMER_SECRET},
);

my $token = $client->get_bearer_token;
$client->access_token($$token{access_token});
my $r = $client->user_timeline(twitterapi => { count => 10 });

for my $status ( @$r ) {
    say "$status->{user}{screen_name}: $status->{text}";
}

