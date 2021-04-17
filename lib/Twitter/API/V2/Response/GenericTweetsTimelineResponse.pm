package Twitter::API::V2::Response::GenericTweetsTimelineResponse;
use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::Tweet::Array';

has meta => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

__PACKAGE__->_mk_deep_accessor(qw/meta/, $_) for qw/
    next_token
    previous_token
    newest_id
    oldest_id
    result_count
/;

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;
