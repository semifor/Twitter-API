#!perl
use 5.14.1;
use warnings;
use Test::Spec;
use HTTP::Response;
use Test::Fatal;

use Twitter::API;

BEGIN {
    eval { require Net::Twitter };
    plan skip_all => 'Net::Twitter >= 4.01041 not installed'
        if $@ || Net::Twitter->VERSION lt '4.01041';
}

my %skip = map +($_ => 1), (
    'contributees',           # deprecated
    'contributors',           # deprecated
    'create_media_metadata',  # described incorrectly in Net::Twitter
    'similar_places',         # no longer documented
    'update_delivery_device', # no longer documented
    'update_profile_colors',  # no longer documented
    'update_with_media',      # deprecated
    'upload_status',          # no longer documented
);

sub new_client {
    my $client = Twitter::API->new_with_traits(
        traits          => 'ApiMethods',
        consumer_key    => 'key',
        consumer_secret => 'secret',
    );
    $client->stubs(request => sub {
        my ( $self, $method, $path, $args ) = @_;
        die 'too many args' if @_ > 4;
        die 'too few args'  if @_ < 3;
        die 'final arg must be HASH' if @_ > 3 && ref $args ne 'HASH';

        return ( uc $method, $args );
    });

    return $client;
}

sub http_response_ok {
    HTTP::Response->new(
        200, 'OK',
        [
            content_type   => 'application/json;charset=utf-8',
            contest_length => 4,
        ],
        '{}'
    );
}

my $nt = Net::Twitter->new(traits => [ qw/API::RESTv1_1/ ]);
my @nt_methods =
    sort { $a->name cmp $b->name }
    grep !$_->deprecated,
    grep $_->isa('Net::Twitter::Meta::Method'),
    $nt->meta->get_all_methods;

for my $nt_method ( @nt_methods ) {
    my $name = $nt_method->name;
    next if $skip{$name};

    my @required = @{ $nt_method->required };

    describe $name => sub {
        my $api;
        before each => sub {
            $api = new_client;
        };

        it 'method exists' => sub {
            ok $api->can($name);
        };
        it 'has correct HTTP method' => sub {
            # path-part arguments must be passed
            my %must_have_args;
            @must_have_args{
                ( $nt_method->path =~ /:(\w+)/g ),
                @required
            } = 'a' .. 'z';
            my ( $http_method, undef ) = $api->$name(
                keys %must_have_args ? \%must_have_args : ()
            );
            is $http_method, $nt_method->method;
        };

        it "handles ${ \(0+@required) }  positional args" => sub {
            my @args; @args[0 .. $#required] = 'a' .. 'z';
            my %expected; @expected{@required} = 'a' .. 'z';
            my ( undef, $args ) = $api->$name(@args);
            is_deeply $args, \%expected;
        } if @required > 0;

        it "handles mixed positional and named args" => sub {
            my %args; @args{@required[1..$#required]} = 'a' .. 'z';
            my %expected; @expected{@required} = ( 'foo', 'a' .. 'z' );
            my ( undef, $args ) = $api->$name('foo', \%args);
            is_deeply $args, \%expected;
        } if @required > 1;
    };
}

runtests;
