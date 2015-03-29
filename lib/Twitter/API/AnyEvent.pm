package Twitter::API::AnyEvent;
# Abstract: uses AnyEvent::HTTP to make asyc requests

use Moo;
use namespace::autoclean;
use strictures 2;
use Carp;
use AnyEvent::HTTP;
use Scalar::Util qw/reftype weaken/;

extends 'Twitter::API';

around request => sub {
    my $orig = shift;
    my $self = shift;

    splice @_, 2, 0, {} unless @_ == 4;
    croak 'expected a callback as the final arg'
        unless ref $_[-1] && reftype $_[-1] eq 'CODE';

    my $c = $self->$orig(@_);
};

sub send_request {
    my ( $self, $c ) = @_;
    weaken $self;

    my $cb = pop @{ $$c{extra_args} };
    my $w; $w = http_request(
        $c->{http_method},
        $c->{uri},
        body    => $c->{body},
        headers => $c->{headers},
        timeout => $self->timeout,
        sub {
            undef $w;
            return unless $cb;
            my ( $body, $headers ) = @_;

            # mock up an HTTP::Tiny response
            $c->{response} = {
                success => scalar $headers->{Status} =~ /^2/,
                status  => $headers->{Status},
                reason  => $headers->{Reason},
                content => $body,
                url     => $headers->{URL},
            };
            $cb->($self->process_response($c), $c);
        }
    );
}

sub process_error_response {
    my ( $self, $c, $data ) = @_;

    return ( undef, $c, $self->error_message($c, $data)  );
}

1;
