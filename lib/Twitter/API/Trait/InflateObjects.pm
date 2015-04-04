package Twitter::API::Trait::InflateObjects;
# ABSTRACT: Inflate hash refs, URLs, and timestamps to objects

use 5.12.1;
use Moo::Role;
use Hash::Objectify;
use Data::Visitor::Callback;
use Regexp::Common qw/URI time/;
use URI;
use Twitter::API::Util qw/timestamp_to_timepiece/;

my $plain_values = sub {
    for ( $_ ) {
        when ( !defined ) {}
        when ( /^$RE{URI}{HTTP}{-scheme => 'https?'}$/ ) {
            $_ = URI->new($_);
        }
        # $RE{time} uses %Z (capital Z) only. The actual format is %z (+0000)
        # which %Z matches just fine, here.
        when ( /^$RE{time}{strftime}{-pat => '%a %b %d %T %Z %Y'}$/ ) {
            $_ = timestamp_to_timepiece($_);
        }
    }
    $_;
};

has objectify_visitor => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        Data::Visitor::Callback->new(
            hash => sub { objectify $_ },
            plain_value => $plain_values,
        );
    },
    handles => { objectify_hashes => 'visit' },
);

around inflate_response => sub {
    my $orig = shift;
    my $self = shift;

    $self->objectify_hashes($self->$orig(@_));
};

1;
