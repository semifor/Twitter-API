package Twitter::API::V2::Response::UsersFollowersLookupResponse;
use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::Object';

has '+data' => (
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
    required => 1,
);

has meta => (
    is  => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

__PACKAGE__->_mk_deep_accessor(qw/meta/, $_) for qw/
    previous_token
    next_token
    result_count
/;

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;

