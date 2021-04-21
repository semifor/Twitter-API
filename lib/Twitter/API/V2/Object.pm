package Twitter::API::V2::Object;
use 5.14.0;

use Moo;
use Sub::Quote;

use namespace::clean;

has data => (
    is  => 'ro',
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

# _mk_deep_accessor
#
# Create an accessor for an arbitrarily deep property. E.g.:
#
#    __PACKAGE__->_mk_deep_accessor(qw/data public_metrics followers_count/);
#
# creates an accessor to $self->{data}{public_metrics}{followers_count} and
# names it followers_count.
#
# If $self->{data} does not exist, it returns undef.
# If $self->{data}{public_metrics} does not exist, it returns undef.
# If $self->{data}{public_metrics}{followers_count} does not exist, it returns
# undef.
# Otherwise, it returns the value of followers_count.
#
# In addition, the accessor will not trigger autovivification. I.e., accessing
# followers_count with:
#
#   $user->{data}{public_metrics}{followers_count}
#
# will create $user->{data}{pubilc_metrics} if it doesn't already exist. While,
# accessing it with _mk_deep_accessar:
#
#   $user->followers_count
#
# will not.

sub _mk_deep_accessor {
    my ( $class, @chain ) = @_;

    quote_sub("${class}::$chain[-1]", q{
            my $r = shift;

            $r &&= $r->{$_} // return for @chain;
            return $r;
        },
        { '@chain' => \@chain }
    );
}

sub _merge_includes {
    my ( $self, $includes ) = @_;

    for my $key ( keys %$includes ) {
        push @{ $self->includes->{$key} }, @{ $includes->{$key} };
    }
}

1;
