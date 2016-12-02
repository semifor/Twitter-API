package Twitter::API::Util;
# ABSTRACT: Exportable utility functions, e.g., Twitter timestamp parsing
$Twitter::API::Util::VERSION = '0.0100'; # TRIAL
use 5.14.1;
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

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Util - Exportable utility functions, e.g., Twitter timestamp parsing

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
