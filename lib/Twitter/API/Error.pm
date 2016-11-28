package Twitter::API::Error;

use Moo;
use strictures 2;
use Try::Tiny;
use namespace::clean;

use overload '""' => sub { shift->message };

with 'Throwable';

has context => (
    is       => 'ro',
    required => 1,
    handles  => [ qw/
        http_request
        http_response
        result
    /],
);

has message => (
    is => 'lazy',
);

sub _build_message {
    my $self = shift;

    my $res = $self->http_response;
    my $data = $self->result;
    my $msg  = join ': ', $res->code, $res->message;
    my $errors = try {
        join ', ' => map "$$_{code}: $$_{message}", @{ $data->{errors} };
    };

    $msg = join ' => ', $msg, $errors if $errors;
    $msg;
}

1;
