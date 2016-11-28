package Twitter::API::Context;
# Abstract: Wraps a twitter response and the http request/response objects

use strictures 2;
use Moo;

has [ qw/http_method args headers extra_args/ ] => (
    is => 'rw',
);

for my $attr ( qw/url result http_response http_request/ ) {
    has $attr => (
        writer => "set_$attr",
        is     => 'ro',
    );
}

# private method
my $limit = sub {
    my ( $self, $which ) = @_;

    my $res = $self->http_response;
    $res->header("X-Rate-Limit-$which");
};

sub rate_limit           { shift->$limit('Limit') }
sub rate_limit_remaining { shift->$limit('Remaining') }
sub rate_limit_reset     { shift->$limit('Reset') }

sub set_header {
    my ( $self, $header, $value ) = @_;

    $self->headers->{$header} = $value;
}

1;
