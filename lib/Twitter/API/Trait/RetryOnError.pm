package Twitter::API::Trait::RetryOnError;
# Abstract: Automatically retry API calls with progressive fallback

use Moo::Role;
use Time::HiRes;
use namespace::clean;

has initial_retry_delay => (
    is      => 'rw',
    default => sub { 0.250 }, # 250 milliseconds
);

has max_retry_delay => (
    is      => 'rw',
    default => sub { 4.0 },   # 4 seconds
);

has retry_delay_multiplier => (
    is      => 'rw',
    default => sub { 2 },     # double the prior delay
);

has max_retries => (
    is        => 'rw',
    default   => sub { 5 },   # 0 = try forever
);

has retry_delay_code => (
    is      => 'rw',
    default => sub {
        sub { Time::HiRes::sleep(shift) };
    },
);

around send_request => sub {
    my $orig = shift;
    my $self = shift;
    my ( $c ) = @_;

    my $msg = $c->http_request;
    my $is_oauth = ( $msg->header('authorization') // '' ) =~ /^OAuth /;

    my $delay = $self->initial_retry_delay;
    my $retries = $self->max_retries;
    my $res;
    while () {
        $res = $self->$orig(@_);

        # return on success or permanent error
        return $res if $res->code < 500 || $retries-- == 0;

        $self->retry_delay_code->($delay);
        $delay *= $self->retry_delay_multiplier;
        $delay  = $self->max_retry_delay if $delay > $self->max_retry_delay;

        # If this is an OAuth request, we need a new Authorization header
        # (the nonce may be invalid, now).
        if ( $is_oauth ) {
            $msg->header(authorization => $self->add_authorization($c));
        }
    }

    $res;
};

1;
