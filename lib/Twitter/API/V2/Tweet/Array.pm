package Twitter::API::V2::Tweet::Array;
# ABSTRACT: encapsulates a Twitter API v2 tweet array response

use Moo;
use Sub::Quote;
use Twitter::API::V2::Response::TweetLookupResponse;
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

# called by Twitter::API::V2::TiedArray

sub _inflate_element {
    my ( $self, $tweet ) = @_;

    return Twitter::API::V2::Tweet->new(
        data     => $tweet,
        includes => $self->includes,
    );
}

1;
