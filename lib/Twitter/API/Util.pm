package Twitter::API::Util;
# ABSTRACT: Exportable utility functions, e.g., Twitter timestamp parsing

use strictures 2;
use Time::Piece;
use Sub::Exporter::Progressive -setup => {
    exports => [ qw/timestamp_to_timepiece timestamp_to_epoch/ ],
};

# "Wed Jun 06 20:07:10 +0000 2012"
my $format = '%a %b %d %T %z %Y';

sub timestamp_to_timepiece { Time::Piece->strptime($_[0], $format) }
sub timestamp_to_epoch     { Time::Piece->strptime($_[0], $format)->epoch }

1;
