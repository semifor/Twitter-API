package Twitter::API::Context;
# ABSTRACT: Encapsulated state for a request/response
$Twitter::API::Context::VERSION = '0.0100'; # TRIAL
use Moo;
use namespace::clean;

has [ qw/http_method args headers extra_args/ ] => (
    is => 'ro',
);

for my $attr ( qw/url result http_response http_request/ ) {
    has $attr => (
        writer => "set_$attr",
        is     => 'ro',
    );
}

has options => (
    is      => 'ro',
    default => sub { {} },
);

sub get_option { $_[0]->options->{$_[1]}         }
sub has_option { exists $_[0]->options->{$_[1]}  }
sub set_option { $_[0]->options->{$_[1]} = $_[2] }
sub delete_option { delete $_[0]->options->{$_[1]} }

# private method
my $limit = sub {
    my ( $self, $which ) = @_;

    my $res = $self->http_response;
    $res->header("X-Rate-Limit-$which");
};

sub rate_limit           { shift->$limit('Limit') }
sub rate_limit_remaining { shift->$limit('Remaining') }
sub rate_limit_reset     { shift->$limit('Reset') }

sub set_header {
    my ( $self, $header, $value ) = @_;

    $self->headers->{$header} = $value;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Context - Encapsulated state for a request/response

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
