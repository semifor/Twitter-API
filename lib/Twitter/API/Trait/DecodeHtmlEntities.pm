package Twitter::API::Trait::DecodeHtmlEntities;
# Abstract: Decode HTML entities in strings

use Moo::Role;
use strictures 2;
use Data::Visitor::Lite;
use HTML::Entities qw/decode_entities/;

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
