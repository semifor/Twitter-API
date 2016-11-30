package Twitter::API::Util;
# ABSTRACT: Exportable utility functions, e.g., Twitter timestamp parsing

use 5.12.1;
use warnings;
use Scalar::Util ();
use Time::Piece;
use Sub::Exporter::Progressive -setup => {
    exports => [ qw/
        is_twitter_api_error
        timestamp_to_timepiece
        timestamp_to_epoch
    /],
};

sub is_twitter_api_error {
    Scalar::Util::blessed($_[0]) && $_[0]->isa('Twitter::API::Error');
}

# "Wed Jun 06 20:07:10 +0000 2012"
my $format = '%a %b %d %T %z %Y';

sub timestamp_to_timepiece { Time::Piece->strptime($_[0], $format) }
sub timestamp_to_epoch     { Time::Piece->strptime($_[0], $format)->epoch }

1;
