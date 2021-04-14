package Twitter::API::V2::Response::UserLookupResponse;
use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::User::Array';

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;

