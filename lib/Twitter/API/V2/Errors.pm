package Twitter::API::V2::Errors;
use Moo::Role;
use Sub::Quote;

use namespace::clean;

has errors => (
    is => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
    predicate => 1,
);

# Easy access to the first error because there's usually only one
sub error {
    shift->errors->[0];
}

around errors => sub {
    my ( $next, $self ) = @_;

    return unless $self->has_errors;

    my @array;
    tie @array, 'Twitter::API::V2::ErrorArray', $self;
    return \@array;
};

package # hide from PAUSE
    Twitter::API::V2::Error;
use Moo;
use Twitter::API::V2::Accessors qw/mk_deep_accessor/;

use namespace::clean;

has problem => (
    is  => 'ro',
);

BEGIN {
    __PACKAGE__->mk_deep_accessor(qw/problem/, $_) for (

        # ProblemFields (all problems have these fields)
        qw/ title detail /,

        # most also have type
        qw/ type /,

        # GenericProblem
        qw/ status /,

        # InvalidRequestProblem
        # ResourceNotFoundProblem
        qw/ parameter value resource_id resource_type /,

        # ResourceUnauthorizedProblem
        qw/ section /, # also: value resource_id resource_type parameter

        # FieldUnauthorizedProblem
        qw/ field /, # also: resource_type section

        # ClientForbiddenProblem
        qw/registration_url required_enrollment reason client_id/, # also: type

        # DisallowedResourceProblem: resource_id resource_type section

        # UnsupportedAuthenticationProblem
        # UsageCapExceededProblem
        # ConnectionExceptionProblem
        # ClientDisconnectedProblem
        # OperationalDisconnectProblem
        # RulesCapProblem
        # InvalidRuleProblem
        # DuplicateRuleProblem
    );
}

package # hide from PAUSE
    Twitter::API::V2::ErrorArray;
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

    my $el = $object->{errors}->[$index] // die "$index out of range";

    return Twitter::API::V2::Error->new(problem => $el);
}

sub FETCHSIZE {
    my $object = ${ shift() };

    scalar @{ $object->{errors} };
}

sub SHIFT     { ... }
sub POP       { ... }
sub CLEAR     { ... }
sub EXISTS    { ... }
sub PUSH      { ... }
sub UNSHIFT   { ... }
sub SPLICE    { ... }
sub STORE     { ... }
sub STORESIZE { ... }
sub DELETE    { ... }
sub EXTEND    { ... }
sub DESTROY   { ... }

1;
