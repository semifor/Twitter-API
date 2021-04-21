package Twitter::API::V2::User::Array;

use Moo;
use Sub::Quote;
use Twitter::API::V2::Response::UserLookupResponse;
use Twitter::API::V2::TiedArray;

use namespace::clean;

use overload
    '@{}' => sub {
        my $self = shift;

        my @array;
        tie @array, 'Twitter::API::V2::TiedArray', $self;
        return \@array;
    },
    fallback => 1;

extends 'Twitter::API::V2::Object';

has '+data' => (
    isa => quote_sub(q{
        die 'is not an ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
    default => sub { [] },
);

sub get_ids {
    return [ map $$_{id}, @{ shift->{data} } ];
}

sub _inflate_element {
    my ( $self, $user ) = @_;

    return Twitter::API::V2::User->new(
        data     => $user,
        includes => $self->includes,
    );
}

1;
