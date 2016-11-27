package Twitter::API::Trait::WrapResult;
# Abstract: Return an object that includes HTTP response, etc.

use strictures 2;
use Moo::Role;
use Twitter::API::WrappedResult;

around inflate_response => sub {
    my $orig = shift;
    my $self = shift;
    my ( $c ) = @_;

    my $data = $self->$orig(@_);

    Twitter::API::WrappedResult->new(
        http_request  => $c->{http_request},
        http_response => $c->{http_response},
        result        => $data,
    );
};

1;
