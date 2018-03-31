package Twitter::API::Trait::RateLimiting;
# ABSTRACT: Automatically sleep as needed to handle rate limiting

use Moo::Role;
use HTTP::Status qw(HTTP_TOO_MANY_REQUESTS);
use namespace::clean;

=attr rate_limit_sleep_code

A coderef, called to implement sleeping.  It takes a single parameter -
the number of seconds to sleep.  The default implementation is:

    sub { sleep shift }

=cut

has rate_limit_sleep_code => (
    is      => 'rw',
    default => sub {
        sub { sleep shift };
    },
);

around send_request => sub {
    my $orig = shift;
    my $self = shift;

    my $res = $self->$orig(@_);

    while($res->code == HTTP_TOO_MANY_REQUESTS) {
        my $sleep_time = $res->header('x-rate-limit-reset') - time;
        $self->rate_limit_sleep_code->($sleep_time);

        $res = $self->$orig(@_);
    }

    return $res;
};

1;

__END__

=pod

=head1 SYNOPSIS

    use Twitter::API;

    my $client = Twitter::API->new_with_options(
        traits => [ qw/ApiMethods RateLimiting/ ],
        %other_options,
    );

    # Use $client as normal

=head1 DESCRIPTION

Twitter's API implements rate limiting in a 15-minute window, and
will serve up an HTTP 429 error if the rate limit is exceeded for
a window.  Applying this trait will give L<Twitter::API> the ability
to automatically sleep as much as is needed and then retry a request
instead of simply throwing an exception.

=head1 SEE ALSO

L<https://developer.twitter.com/en/docs/basics/rate-limiting>

=cut
