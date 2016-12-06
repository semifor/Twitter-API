package Net::Twitter::Trait::DecodeHtmlEntities;
# ABSTRACT: Decode HTML entities in strings

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

=head1 SYNOPSIS

    use Net::Twitter;
    use open qw/:std :utf8/;

    my $client = Net::Twitter->new_with_traits(
        traits => [ qw/ApiMethods DecodeHtmlEntites/ ],
        %other_options
    );

    my $status = $client->show_status(801814387723935744);
    say $status->{text};

    # output:
    # Test DecodeHtmlEntities trait. < & > ⚠️ 🏉 'single' "double"
    #
    # output without the DecodeHtmlEntities trait:
    # Test DecodeHtmlEntities trait. &lt; &amp; &gt; ⚠️ 🏉 'single' "double"

=head1 DESCRIPTION

Twitter has trust issues. They assume you're going to push the text you receive
in API responses to a web page without HTML encoding it. But you HTML encode
all of your output right? And Twitter's lack of trust has you double encoding
entities.

So, include this trait and Net::Twitter will decode HTML entities in all of the
text returned by the API.

You're welcome.

=cut
