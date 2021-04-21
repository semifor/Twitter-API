package Twitter::API::V2::TiedArray;
use strict;
use warnings;

sub TIEARRAY {
    my ( $class, $tied_object ) = @_;

    bless \$tied_object, $class;
}

# return a Twitter::API::V2::Tweet with includes
sub FETCH {
    my $object = ${ shift() };
    my $index = shift;

    my $el = $object->data->[$index] // die "$index out of range";

    return $object->_inflate_element($el);
}

sub FETCHSIZE {
    my $object = ${ shift() };

    scalar @{ $object->data };
}

# return a Twitter::API::V2::Tweet with includes
sub SHIFT {
    my $object = ${ shift() };

    my $el = shift @{ $object->data } // return;

    my $r = $object->_inflate_element($el);
    $object->_clear_includes unless @{ $object->data };

    return $r;
}

# return a Twitter::API::V2::Tweet with includes
sub POP {
    my $object = ${ shift() };

    my $el = pop @{ $object->data } // return;

    my $r = $object->_inflate_element($el);
    $object->_clear_includes unless @{ $object->data };

    return $r;
}

sub CLEAR {
    my $object = ${ shift() };

    $object->_clear_data;
    $object->_clear_includes;
}

sub EXISTS {
    my $object = ${ shift() };
    my $index = shift;

    exists $object->data->[$index];
}

# push:
# - Twitter::API::V2::Tweet objects
# - Twitter::API::V2::Tweet::Array objects
# - Raw Twitter API response tweets
# - Raw Twitter API response tweet arrays
sub PUSH {
    my $object = ${ shift() };

    for my $push ( @_ ) {
        my $data = $$push{data} // die 'unexpected data';
        if ( ref $data eq 'HASH' ) {
            push @{ $object->data }, $data;
        }
        elsif ( ref $data eq 'ARRAY' ) {
            push @{ $object->data }, @$data;
        }
        else {
            die 'unexpected data' unless exists $$push{data};
        }

        if ( my $includes = $$push{includes} ) {
            $object->_merge_includes($includes);
        }
    }

    return scalar @{ $object->data };
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

1;
