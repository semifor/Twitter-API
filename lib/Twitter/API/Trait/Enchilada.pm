package Twitter::API::Trait::Enchilada;
# ABSTRACT: Sometimes you wan the whole enchilada

use Moo::Role;

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

=head1 SYNOPSIS

    use Twitter::API;

    my $api = Twitter::API->new_with_traits(
        traits => 'Enchilada',
        %other_new_options
    );

    # which is just shorthand for:
    my $api = Twitter::API->new_with_traits(
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

=cut
