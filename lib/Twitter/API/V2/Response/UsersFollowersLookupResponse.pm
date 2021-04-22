package Twitter::API::V2::Response::UsersFollowersLookupResponse;
use Moo;
use Sub::Quote;
use Twitter::API::V2::Accessors qw/mk_deep_accessor/;

use namespace::clean;

extends 'Twitter::API::V2::User::Array';

has meta => (
    is  => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

BEGIN {
    __PACKAGE__->mk_deep_accessor(qw/meta/, $_) for qw/
        previous_token
        next_token
        result_count
    /;
}

1;

