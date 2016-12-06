package Net::Twitter::Trait::Enchilada;
# ABSTRACT: Sometimes you want the whole enchilada

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

=head1 SYNOPSIS

    use Net::Twitter;

    my $client = Net::Twitter->new_with_traits(
        traits => 'Enchilada',
        %other_new_options
    );

=head1 DESCRIPTION

This is just a shortcut for applying commonly used traits. Because, sometimes, you just want the whole enchilada.

This role simply bundles the following traits. See those modules for details.

=for :list
* L<ApiMethods|Net::Twitter::Trait::ApiMethods>
* L<NormalizeBooleans|Net::Twitter::Trait::NormalizeBooleans>
* L<RetryOnError|Net::Twitter::Trait::RetryOnError>
* L<DecodeHtmlEntites|Net::Twitter::Trait::DecodeHtmlEntities>

=cut
