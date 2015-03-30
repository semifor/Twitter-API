package Twitter::API::AnyEvent;
# Abstract: uses AnyEvent::HTTP to make asyc requests

use Moo;
use namespace::autoclean;
use strictures 2;
use Carp;
use AnyEvent::HTTP::Request;
use AnyEvent::HTTP::Response;
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
    my ( $self, $c, $req ) = @_;
    weaken $self;

    my $cb = pop @{ $$c{extra_args} };
    my $w;
    my $ae_req = AnyEvent::HTTP::Request->new($req, {
        params => {
            timeout => $self->timeout,
        },
        cb => sub {
            undef $w;
            my $res = AnyEvent::HTTP::Response->new(@_);

            $cb->($self->process_response($c, $res->to_http_message));
        }
    });

    $w = $ae_req->send;
}

sub process_error_response {
    my ( $self, $c, $res, $data ) = @_;

    return ( undef, $c, $res, $self->error_message($c, $res, $data)  );
}

1;
