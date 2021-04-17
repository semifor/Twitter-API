package Twitter::API::V2::Tweet::Array;
# ABSTRACT: encapsulates a Twitter API v2 tweet array response

use Moo;
use Sub::Quote;
use Twitter::API::V2::Response::TweetLookupResponse;

use namespace::clean;

use overload
    '@{}' => sub {
        my $self = shift;

        my @array;
        tie @array, ref $self, $self;
        return \@array;
    },
    fallback => 1;

extends 'Twitter::API::V2::Object';

has data => (
    is  => 'ro',
    isa => quote_sub(q{
        die 'is not an ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
    default => sub { [] },
    clearer  => '_clear_data',
);

has includes => (
    is      => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    clearer => '_clear_includes',
    default => sub { {} },
);

sub _inflate_tweet {
    my ( $self, $tweet ) = @_;

    return Twitter::API::V2::Tweet->new(
        data     => $tweet,
        includes => $self->includes,
    );
}

sub TIEARRAY {
    my $class = shift;

    bless \shift, $class;
}

# return a Twitter::API::V2::Tweet with includes
sub FETCH {
    my $self = ${ shift() };
    my $index = shift;

    my $tweet = $self->data->[$index] // die "$index out of range";

    return $self->_inflate_tweet($tweet);
}

sub FETCHSIZE {
    my $self = ${ shift() };
    scalar @{ $self->data };
}

# return a Twitter::API::V2::Tweet with includes
sub SHIFT {
    my $self = ${ shift() };

    my $tweet = shift @{ $self->data } // return;

    my $r = $self->_inflate_tweet($tweet);
    $self->_clear_includes unless @{ $self->data };

    return $r;
}

# return a Twitter::API::V2::Tweet with includes
sub POP {
    my $self = ${ shift() };

    my $tweet = pop @{ $self->data } // return;

    my $r = $self->_inflate_tweet($tweet);
    $self->_clear_includes unless @{ $self->data };

    return $r;
}

sub CLEAR {
    my $self = ${ shift() };

    $self->_clear_data;
    $self->_clear_includes;
}

sub EXISTS {
    my $self = ${ shift() };
    my $index = shift;

    exists $self->{data}[$index];
}

# push:
# - Twitter::API::V2::Tweet objects
# - Twitter::API::V2::Tweet::Array objects
# - Raw Twitter API response tweets
# - Raw Twitter API response tweet arrays
sub PUSH {
    my $self = ${ shift() };

    for my $push ( @_ ) {
        my $data = $$push{data} // die 'unexpected data';
        if ( ref $data eq 'HASH' ) {
            push @{ $self->data }, $data;
        }
        elsif ( ref $data eq 'ARRAY' ) {
            push @{ $self->data }, @$data;
        }
        else {
            die 'unexpected data' unless exists $$push{data};
        }

        if ( my $includes = $$push{includes} ) {
            $self->_merge_includes($includes);
        }
    }

    return scalar @{ $self->data };
}

sub UNSHIFT { ... }
sub SPLICE { ... }

# unimplemented
sub STORE { ... }       # mandatory if elements writeable
sub STORESIZE { ... }   # mandatory if elements can be added/deleted
sub DELETE { ... }      # mandatory if delete() expected to work

# optional methods - for efficiency
sub EXTEND { ... }
sub DESTROY { ... }

sub _merge_includes {
    my ( $self, $includes ) = @_;

    for my $key ( keys %$includes ) {
        push @{ $self->includes->{$key} }, @{ $includes->{$key} };
    }
}

1;
