package Twitter::API::V2::Accessors;
use strict;
use warnings;
use parent 'Exporter';
use Sub::Quote;

our @EXPORT_OK = qw/mk_deep_accessor/;

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

sub mk_deep_accessor {
    my ( $class, @chain ) = @_;

    quote_sub("${class}::$chain[-1]", q{
            my $r = shift;

            $r &&= $r->{$_} // return for @chain;
            return $r;
        },
        { '@chain' => \@chain }
    );
}

1;
