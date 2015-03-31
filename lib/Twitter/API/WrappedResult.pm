package Twitter::API::WrappedResult;
# Abstract: Wraps a twitter response and the http request/response objects

use strictures 2;
use Moo;

has [ qw/result http_response http_request/ ] => (
    is       => 'ro',
    required => 1,
);

# private method
my $limit = sub {
    my ( $self, $which ) = @_;

    my $res = $self->http_response;
    $res->header("X-Rate-Limit-$which");
};

sub rate_limit           { shift->$limit('Limit') }
sub rate_limit_remaining { shift->$limit('Remaining') }
sub rate_limit_reset     { shift->$limit('Reset') }

1;
