requires perl => '5.14.1';

requires 'Carp';
requires 'Class::Load';
requires 'Data::Visitor::Lite';
requires 'Devel::StackTrace';
requires 'Digest::SHA';
requires 'Encode';
requires 'HTML::Entities';
requires 'HTTP::Request::Common';
requires 'HTTP::Thin';
requires 'IO::Socket::SSL';
requires 'JSON::MaybeXS';
requires 'Moo';
requires 'Moo::Role';
requires 'MooX::Aliases';
requires 'MooX::Traits';
requires 'namespace::clean';
requires 'Net::OAuth';
requires 'Scalar::Util';
requires 'Sub::Exporter::Progressive';
requires 'Throwable';
requires 'Time::HiRes';
requires 'Time::Local';
requires 'Try::Tiny';
requires 'URI';
requires 'URL::Encode';

on test => sub {
    requires 'Test::Fatal';
    requires 'Test::More';
    requires 'Test::Spec';
    requires 'Test::Warnings';
};
