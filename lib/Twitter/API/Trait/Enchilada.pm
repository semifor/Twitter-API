package Twitter::API::Trait::Enchilada;
# ABSTRACT: Sometimes you wan the whole enchilada
$Twitter::API::Trait::Enchilada::VERSION = '0.0100'; # TRIAL
use Moo::Role;
use namespace::clean;

# because you usually want the whole enchilada

my $namespace = __PACKAGE__ =~ s/\w+$//r;
with map join('', $namespace, $_), qw/
    ApiMethods
    NormalizeBooleans
    RetryOnError
    DecodeHtmlEntities
/;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::Enchilada - Sometimes you wan the whole enchilada

=head1 VERSION

version 0.0100

=head1 SYNOPSIS

    use Twitter::API;

    my $client = Twitter::API->new_with_traits(
        traits => 'Enchilada',
        %other_new_options
    );

    # which is just shorthand for:
    my $client = Twitter::API->new_with_traits(
        traits => [ qw/
            ApiMethods
            NormalizeBooleans
            RetryOnError
            DecodeHtmlEntities
        /],
        %other_new_options
    );

=head1 DESCRIPTION

This is just a shortcut for applying traits ApiMethods, NormalizeBooleans,
RetryOnError, and DecodeHtmlEntities. Because sometimes you just want the whole
enchilada.

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
