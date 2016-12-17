package Twitter::API::Error;
# ABSTRACT: Twitter API exception

use Moo;
use Try::Tiny;
use namespace::clean;

use overload '""' => sub { shift->error };

with qw/Throwable StackTrace::Auto/;

=method http_request

Returns the L<HTTP::Request> object used to make the Twitter API call.

=method http_response

Returns the L<HTTP::Response> object for the API call.

=method twitter_error

Returns the inflated JSON error response from Twitter (if any).

=cut

has context => (
    is       => 'ro',
    required => 1,
    handles  => {
        http_request  => 'http_request',
        http_response => 'http_response',
        twitter_error => 'result',
    },
);

=method stack_trace

Returns a L<Devel::StackTrace> object encapsulating the call stack so you can discover, where, in your application the error occurred.

=method stack_frame

Delegates to C<< stack_trace->frame >>. See L<Devel::StackTrace> for details.

=method next_stack_fram

Delegates to C<< stack_trace->next_frame >>. See L<Devel::StackTrace> for details.

=cut

has '+stack_trace' => (
    handles => {
        stack_frame      => 'frame',
        next_stack_frame => 'next_frame',
    },
);

=method error

Returns a reasonable string representation of the exception. If Twitter
returned error information in the form of a JSON body, it is mined for error
text. Otherwise, the HTTP response status line is used. The stack frame is
mined for the point in your application where the request initiated and
appended to the message.

When used in a string context, C<error> is called to stringify exception.

=cut

has error => (
    is => 'lazy',
);

sub _build_error {
    my $self = shift;

    my $error = $self->twitter_error_text || $self->http_response->status_line;
    my ( $location ) = $self->stack_frame(0)->as_string =~ /( at .*)/;
    return $error . ($location || '');
}

sub twitter_error_text {
    my $self = shift;
    # Twitter does not return a consistent error structure, so we have to
    # try each known (or guessed) variant to find a suitable message...

    return '' unless $self->twitter_error;
    my $e = $self->twitter_error;

    return ref $e eq 'HASH' && (
        # the newest variant: array of errors
        exists $e->{errors}
            && ref $e->{errors} eq 'ARRAY'
            && exists $e->{errors}[0]
            && ref $e->{errors}[0] eq 'HASH'
            && exists $e->{errors}[0]{message}
            && $e->{errors}[0]{message}

        # it's single error variant
        || exists $e->{error}
            && ref $e->{error} eq 'HASH'
            && exists $e->{error}{message}
            && $e->{error}{message}

        # the original error structure (still applies to some endpoints)
        || exists $e->{error} && $e->{error}

        # or maybe it's not that deep (documentation would be helpful, here,
        # Twitter!)
        || exists $e->{message} && $e->{message}
    ) || ''; # punt
}

=method twitter_error_code

Returns the numeric error code returned by Twitter, or 0 if there is none. See
L<https://dev.twitter.com/overview/api/response-codes> for details.

=cut

sub twitter_error_code {
    my $self = shift;

    for ( $self->twitter_error ) {
        return ref $_ eq 'HASH'
            && exists $_->{errors}
            && exists $_->{errors}[0]
            && exists $_->{errors}[0]{code}
            && $_->{errors}[0]{code}
            || 0;
    }
}

=method is_token_error

Returns true if the error represents a problem with the access token or its
Twitter account, rather than with the resource being accessed.

Some Twitter error codes indicate a problem with authentication or the
token/secret used to make the API call. For example, the account has been
suspended or access to the application revoked by the user. Other error codes
indicate a problem with the resource requested. For example, the target account
no longer exists.

is_token_error returns true for the following Twitter API errors:

=for :list
* 32: Could not authenticate you
* 64: Your account is suspended and is not permitted to access this feature
* 88: Rate limit exceeded
* 89: Invalid or expired token
* 99: Unable to verify your credentials.
* 135: Could not authenticate you
* 136: You have been blocked from viewing this user's profile.
* 215: Bad authentication data
* 226: This request looks like it might be automated. To protect our users from
  spam and other malicious activity, we can’t complete this action right now.
* 326: To protect our users from spam…

For error 215, Twitter's API documentation says, "Typically sent with 1.1
responses with HTTP code 400. The method requires authentication but it was not
presented or was wholly invalid." In practice, though, this error seems to be
spurious, and often succeeds if retried, even with the same tokens.

The Twitter API documentation describes error code 226, but in practice, they
use code 326 instead, so we check for both. This error code means the account
the tokens belong to has been locked for spam like activity and can't be used
by the API until the user takes action to unlock their account.

See Twitter's L<Error Codes &
Responses|https://dev.twitter.com/overview/api/response-codes> documentation
for more information.

=cut

use constant TOKEN_ERRORS => (32, 64, 88, 89, 99, 135, 136, 215, 226, 326);
my %token_errors = map +($_ => undef), TOKEN_ERRORS;

sub is_token_error {
    exists $token_errors{shift->twitter_error_code};
}

=method http_response_code

Delegates to C<< http_response->code >>. Returns the HTTP status code of the
response.

=cut

sub http_response_code { shift->http_response->code }

=method is_pemanent_error

Returns true for HTTP status codes representing an error and with values less
than 500. Typically, retrying an API call with one of these statuses right away
will simply result in the same error, again.

=cut

sub is_permanent_error { shift->http_response_code < 500 }

=method is_temporary_error

Returns true or HTTP status codes of 500 or greater. Often, these errors
indicate a transient condition. Retrying the API call right away may result in
success. See the L<RetryOnError|Twitter::API::Trait::RetryOnError> for
automatically retrying temporary errors.

=cut

sub is_temporary_error { !shift->is_permanent_error }

1;

__END__

=pod

=head1 SYNOPSIS

    use Try::Tiny;
    use Twitter::API;
    use Twitter::API::Util 'is_twitter_api_error';

    my $client = Twitter::API->new(%options);

    try {
        my $r = $client->get('account/verify_credentials');
    }
    catch {
        die $_ unless is_twitter_api_error;

        warn "Twitter says: ", $_->twitter_error_text;
    };

=head1 DESCRIPTION

Twitter::API dies, throwing a Twitter::API::Error exception when it receives an
error. The error object contains information about the error so your code can
decide how to respond to various error conditions.

=cut
