package Twitter::API::Trait::RetryOnError;
# ABSTRACT: Automatically retry API calls on error

use Moo::Role;
use Time::HiRes;
use namespace::clean;

=attr initial_retry_delay

Amount of time to delay before the initial retry. Specified in fractional
seconds. Default: 0.25 (250ms).

=cut

has initial_retry_delay => (
    is      => 'rw',
    default => sub { 0.250 }, # 250 milliseconds
);

=attr max_retry_delay

Maximum delay between retries, specified in fractional seconds. Default: 4.0.

=cut

has max_retry_delay => (
    is      => 'rw',
    default => sub { 4.0 },   # 4 seconds
);

=attr retry_delay_multiplier

After the initial delay, the delay time is multiplied by this factor to
progressively back off allowing more time for the transient condition to
resolve. However, the delay never exceeds C<max_retry_delay>. Default: 2.0.

=cut

has retry_delay_multiplier => (
    is      => 'rw',
    default => sub { 2 },     # double the prior delay
);

=attr max_retries

Maximum number of times to retry on error. Default: 5.

=cut

has max_retries => (
    is        => 'rw',
    default   => sub { 5 },   # 0 = try forever
);

=attr retry_delay_code

A coderef, called to implement a delay. It takes a single parameter, the number
of seconds to delay. E.g., 0.25. The default implementation is simply:

    sub { Time::HiRes::sleep(shift) }

=cut

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

=head1 SYNOPSIS

    use Twitter::API;

    my $client = Twitter::API->new_with_options(
        traits => [ qw/ApiMethods RetryOnError/ ],
        %other_optons
    );

    my $statuses = $client->home_timeline;

=head1 DESCRIPTION

With this trait applied, Twitter::API automatically retries API calls that
result in an HTTP status code of 500 or greater. These errors often indicate a
temporary problem, either on Twitter's end, locally, or somewhere in between.
By default, it retries up to 5 times. The initial retry is delayed by 250ms.
Additional retries double the delay time until the maximum delay is reached
(default: 4 seconds). Twitter::API throws a C<Twitter::API::Error> exception
when it receives a permanent error (HTTP status code below 500), or the maximum
number of retries has been reached.

For non-blocking applications, set a suitable C<retry_delay_code> callback.
This attribute can also be used to provided retry logging.

1;
