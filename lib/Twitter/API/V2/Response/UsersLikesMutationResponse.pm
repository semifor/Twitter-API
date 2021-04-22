package Twitter::API::V2::Response::UsersLikesMutationResponse;
use Moo;
use Sub::Quote;
use Twitter::API::V2::Accessors qw/mk_deep_accessor/;

# The spec at https://api.twitter.com/2/openapi.json references two response types:
# - UsersLikesCreateResponse
# - UsersLikesDeleteResponse
#
# They both have the same schema, so we'll just use one class to represent them.

use namespace::clean;

extends 'Twitter::API::V2::Object';

with 'Twitter::API::V2::Errors';

has '+data' => (
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

BEGIN {
    __PACKAGE__->mk_deep_accessor(qw/data/, $_) for qw/
        liked
    /;
}

1;

