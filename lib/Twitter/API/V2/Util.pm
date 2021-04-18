package Twitter::API::V2::Util;
# ABSTRACT: Utility functions for Twitter API V2

use 5.12.1;
use warnings;
use parent qw/Exporter/;
use Time::Local qw/timegm/;

# Offset, in milliseconds, from Unux epoch to Twitter Snowflake epoch.
use constant TWITTER_SNOWFLAKE_EPOCH => 1288834974657;

our @EXPORT_OK = qw/
    time_from_iso_8601
    time_from_snowflake_id
/;

sub time_from_iso_8601 {
    my $iso8601 = shift // return;

    # "2009-12-22T13:26:16.000Z"
    my ( $y, $mo, $d, $h, $m, $s ) =  $iso8601 =~
        /^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)\.\d\d\dZ$/;
    return timegm($s, $m, $h, $d, $mo - 1, $y - 1900);
}

# https://ws-dl.blogspot.com/2019/08/2019-08-03-tweetedat-finding-tweet.html
#
# Snowflake ID:
# - 41 bit timestamp with millisecond resolution
# - 10 bit machine ID
# - 12 bit sequence number
#
sub time_from_snowflake_id {
    int(((shift >> 22) + TWITTER_SNOWFLAKE_EPOCH) / 1000);
}

1;
