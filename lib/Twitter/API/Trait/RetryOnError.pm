package Twitter::API::Trait::RetryOnError;
# ABSTRACT: Automatically retry API calls
$Twitter::API::Trait::RetryOnError::VERSION = '0.0100'; # TRIAL
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

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::RetryOnError - Automatically retry API calls

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
