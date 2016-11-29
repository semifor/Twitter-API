package Twitter::API::Error;

use Moo;
use strictures 2;
use Try::Tiny;
use Devel::StackTrace;
use namespace::clean;

use overload '""' => sub { shift->error };

with 'Throwable';

has context => (
    is       => 'ro',
    required => 1,
    handles  => {
        http_request  => 'http_request',
        http_response => 'http_response',
        twitter_error => 'result',
    },
);

has stack_trace => (
    is       => 'ro',
    init_arg => undef,
    builder  => '_build_stack_trace',
    handles => {
        stack_frame => 'frame',
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

sub twitter_error_code {
    my $self = shift;

    return $self->twitter_error
        && exists $self->twitter_error->{errors}
        && exists $self->twitter_error->{errors}[0]
        && exists $self->twitter_error->{errors}[0]{code}
        && $self->twitter_error->{errors}[0]{code}
        || 0;
}

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

# Expect the same error if you retry right away
sub is_permanent_error { shift->http_response->code < 500 }

# Might work if you retry again right away
sub is_temporary_error { !shift->is_permanent_error }

1;
