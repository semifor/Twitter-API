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

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

sub next_token {
    shift->meta->{next_token};
}

sub previous_token {
    shift->meta->{previous_token};
}

sub newest_id {
    shift->meta->{newest_id};
}

sub oldest_id {
    shift->meta->{oldest_id};
}

sub result_count {
    shift->meta->{result_count};
}

1;
