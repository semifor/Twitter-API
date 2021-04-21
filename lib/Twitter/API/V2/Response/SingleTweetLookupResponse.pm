package Twitter::API::V2::Response::SingleTweetLookupResponse;
# ABSTRACT: encapsulates a Twitter API v2 tweet
use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::Tweet';

has errors => (
    is       => 'ro',
    isa      => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;