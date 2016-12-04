package Twitter::API::Error;
# ABSTRACT: Twitter API exception

use Moo;
use Try::Tiny;
use Devel::StackTrace;
use namespace::clean;

use overload '""' => sub { shift->error };

with 'Throwable';

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

Delegates to C<<stack_trace->frame>>. See L<Devel::StackTrace> for details.

=method next_stack_fram

Delegates to C<<stack_trace->next_frame>>. See L<Devel::StackTrace> for details.

=cut

has stack_trace => (
    is       => 'ro',
    init_arg => undef,
    builder  => '_build_stack_trace',
    handles => {
        stack_frame      => 'frame',
        next_stack_frame => 'next_frame',
    },
);

sub _build_stack_trace {
    my $seen;
    my $this_sub = (caller 0)[3];
    Devel::StackTrace->new(frame_filter => sub {
        my $caller = shift->{caller};
        my $skip = $caller->[0] =~ /^(?:Twitter::API|Throwable|Role::Tiny)\b/
            || $caller->[3] eq $this_sub;
        ($seen ||= $skip) && !$skip || 0;
    });
}

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

    return $self->twitter_error
        && exists $self->twitter_error->{errors}
        && exists $self->twitter_error->{errors}[0]
        && exists $self->twitter_error->{errors}[0]{code}
        && $self->twitter_error->{errors}[0]{code}
        || 0;
}

=method is_token_error

Returns true if the error represents a problem with the access token or its
Twitter account, rather than with the resource being accessed.

Some Twitter error codes indicate a problem with authentication or the
token/secret used to make the API call. For example, the account has been
suspended or access to the application revoked by the user. Other error codes
indicate a problem with the resource requested. For example, the target account
no longer exists.

=cut

# Some twitter errors result from issues with the target of a call. Others,
# from an issue with the tokens used to make the call. In the latter case, we
# should just retry with fresh tokens. Return true for the latter type.
sub is_token_error {
    my $self = shift;

    # 32:  could not authenticate you
    # 64:  this account is suspended
    # 88:  rate limit exceeded for this token
    # 89:  invalid or expired tokens
    #
    # Twitter documents error 226 as spam/bot-like behavior,
    # but they actually send 326! So, we'll look for both.
    # 226: this account locked for bot-like behavior
    # 326: To protect our users from spam...
    my $code = $self->twitter_error_code;
    for ( 32, 64, 88, 89, 226, 326 ) {
        return 1 if $_ == $code;
    }
    return 0;
}

=method http_response_code

Delegates to C<<http_response->code>>. Returns the HTTP status code of the
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
        die $_ unless _is_twitter_api_error;

        warn "Twitter says: ", $_->twitter_error_text;
    };

=head1 DESCRIPTION

Twitter::API dies, throwing a Twitter::API::Error exception when it receives an
error. The error object contains information about the error so your code can
decide how to respond to various error conditions.

=cut
