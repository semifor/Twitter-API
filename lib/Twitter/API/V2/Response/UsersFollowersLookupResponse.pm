package Twitter::API::V2::Response::UsersFollowingCreateResponse;
use Moo;
use Sub::Quote;

use namespace::clean;

extends 'Twitter::API::V2::Object';

has data => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

__PACKAGE__->_mk_deep_accessor(qw/data/, $_) for qw/
    following
    pending_follow
/;

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

1;

