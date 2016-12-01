#!perl
use 5.14.1;
use strict;
use Test::Fatal;
use Test::Spec;

package Foo {
    use Moo;
    use Carp;
    with 'Twitter::API::Trait::ApiMethods';

    sub request {
        my ( $self, $http_method, $url, $args ) = @_;
        croak 'too many args' if @_ > 4;
        croak 'too few args'  if @_ < 4;
        croak 'final arg must be HASH' unless ref $args eq 'HASH';

        return $args;
    }
}


describe _with_pos_args => sub {
    my $api;
    before each => sub {
        $api = Foo->new;
    };

    it 'croaks without args' => sub{
        like exception {
            $api->_with_pos_args([':ID'], 'GET', 'path');
        }, qr/missing required screen_name or user_id/;
    };
    it ':ID croaks with both screen_name or user_id' => sub {
        exception {
            $api->_with_pos_args([':ID'], GET => 'path', {
                screen_name => 'twinsies',
                user_id     => '666',
            });
        }, qr/only one of screen_name or user_id allowed/;
    },
    it 'croaks with too many args' => sub {
        like exception {
            $api->_with_pos_args([':ID'], 'GET', 'path', 'who', 'extra');
        }, qr/too many args/;
    },
    it ':ID croaks without user_id or screen_name' => sub {
        like exception {
            $api->_with_pos_args([':ID'], GET => 'path', { foo => 'bar' });
        }, qr/missing required screen_name or user_id/;
    },
    it 'croaks without required args' => sub {
        like exception {
            $api->_with_pos_args([ qw/foo bar/ ], GET => 'path', {
                foo => 'baz',
            });
        }, qr/missing required 'bar' arg/;
    },
    it 'croaks with duplicate args' => sub {
        like exception {
            $api->_with_pos_args(['foo'], GET => 'path', 'bar', {
                foo => 'baz',
            });
        }, qr/'foo' specified in both positional and named args/;
    };
    it 'croaks with duplicate :ID' => sub {
        like exception {
            $api->_with_pos_args([':ID'], GET => 'path', 'bar', {
                screen_name => 'baz',
            });
        }, qr/'screen_name' specified in both positional and named args/;
    };
    it ':ID handles user_id' => sub {
        my $args = $api->_with_pos_args([':ID'], GET => 'path', 666, {
            foo => 'bar',
        });
        is_deeply $args, { user_id => 666, foo => 'bar' };
    };
    it ':ID handles screen_name' => sub {
        my $args = $api->_with_pos_args([':ID'], GET => 'path', 'evil', {
            foo => 'bar',
        });
        is_deeply $args, { screen_name => 'evil', foo => 'bar' };
    };
    it 'handles pos args in the hash' => sub {
        my $args = $api->_with_pos_args([ qw/foo bar/ ], GET => 'path',
            'baz', { bar => 'bop', and => 'more' }
        );
        is_deeply $args, { foo => 'baz', bar => 'bop', and => 'more' };
    };
};

runtests;
