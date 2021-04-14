package Twitter::API::V2::Util;
# ABSTRACT: Utility functions for Twitter API V2

use 5.12.1;
use warnings;
use parent qw/Exporter/;
use Time::Local qw/timegm/;

our @EXPORT_OK = qw/
    time_from_iso_8601
/;

sub time_from_iso_8601 {
    my $iso8601 = shift->created_at // return;

    # "2009-12-22T13:26:16.000Z"
    my ( $y, $mo, $d, $h, $m, $s ) =  $iso8601 =~
        /^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)\.\d\d\dZ$/;
    return timegm($s, $m, $h, $d, $mo - 1, $y - 1900);
}

1;
