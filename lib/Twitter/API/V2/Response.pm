package Twitter::API::V2::Response;
# ABASTRACT: base type for Twitter API Responses

use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::Object';

# All API responses may errors
has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;

