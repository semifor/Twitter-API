package Twitter::API::Trait::DecodeHtmlEntities;
# ABSTRACT: Decode HTML entities in strings
$Twitter::API::Trait::DecodeHtmlEntities::VERSION = '0.0100'; # TRIAL
use Moo::Role;
use Data::Visitor::Lite;
use HTML::Entities qw/decode_entities/;
use namespace::clean;

has _entities_visitor => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        Data::Visitor::Lite->new(
            [ -value => sub { decode_entities($_[0]) } ]
        ),
    },
    handles => { _decode_html_entities => 'visit' },
);

around inflate_response => sub {
    my ( $orig, $self, $c ) = @_;

    $self->$orig($c);
    my $r = $self->_decode_html_entities($c->result);
    $c->set_result($r);
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::DecodeHtmlEntities - Decode HTML entities in strings

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
