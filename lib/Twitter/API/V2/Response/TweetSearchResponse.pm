package Twitter::API::V2::Response::TweetSearchResponse;
use Moo;
use Sub::Quote;
use Twitter::API::V2::Accessors qw/mk_deep_accessor/;

# Same as GenericTweetsTimelineResponse but without previous_token

use namespace::clean;

extends 'Twitter::API::V2::Tweet::Array';

with 'Twitter::API::V2::Errors';

has meta => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

BEGIN {
    __PACKAGE__->mk_deep_accessor(qw/meta/, $_) for qw/
        next_token
        newest_id
        oldest_id
        result_count
    /;
}

1;
