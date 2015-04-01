package Twitter::API::Traits::WrapResult;
# Abstract: Return an object that includes HTTP response, etc.

use strictures 2;
use Moo::Role;
use Twitter::API::WrappedResult;

around inflate_response => sub {
    my $orig = shift;
    my $self = shift;
    my ( $c, $res ) = @_;

    my $data = $self->$orig(@_);

    Twitter::API::WrappedResult->new(
        result        => $data,
        http_response => $res,
        http_request  => $c->{http_request},
    );
};

1;
