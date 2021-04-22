package Twitter::API::V2::Object;
use 5.14.0;

use Moo;
use Sub::Quote;

use namespace::clean;

has data => (
    is  => 'ro',
    clearer  => '_clear_data',
);

has includes => (
    is      => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    clearer => '_clear_includes',
    default => sub { {} },
);

sub _merge_includes {
    my ( $self, $includes ) = @_;

    for my $key ( keys %$includes ) {
        push @{ $self->includes->{$key} }, @{ $includes->{$key} };
    }
}

1;
