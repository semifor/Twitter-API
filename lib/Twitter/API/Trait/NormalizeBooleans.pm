package Twitter::API::Trait::NormalizeBooleans;
# ABSTRACT: Normalize Booleans
$Twitter::API::Trait::NormalizeBooleans::VERSION = '0.0100'; # TRIAL
use 5.14.1;
use Moo::Role;
use namespace::clean;

requires 'preprocess_args';

around preprocess_args => sub {
    my ( $next, $self, $c ) = @_;

    $self->$next($c);
    $self->normalize_bools($c->args);
};

# Twitter usually accepts 1, 't', 'true', or false for booleans, but they
# prefer 'true' or 'false'. In some cases, like include_email, they only accept
# 'true'. So, we normalize these options.
my @normal_bools = qw/
    contributor_details display_coordinates exclude_replies hide_media
    hide_thread hide_tweet include_email include_entities include_my_tweet
    include_rts include_user_entities map omit_script possibly_sensitive
    reverse trim_user
/;

# Workaround Twitter bug: any value passed for these options are treated as
# true.  The only way to get 'false' is to not pass the skip_user at all. So,
# we strip these boolean args if their values are false.
my @true_only_bools = qw/skip_status skip_user/;

my %is_bool = map { $_ => undef } @normal_bools, @true_only_bools;
my %is_true_only_bool = map { $_ => undef } @true_only_bools;

sub is_bool { exists $is_bool{$_[1]} }

sub is_true_only_bool { exists $is_true_only_bool{$_[1]} }

sub normalize_bools {
    my ( $self, $args ) = @_;

    # Twitter prefers 'true' or 'false' (requires it in some cases).
    for my $k ( keys %$args ) {
        next unless $self->is_bool($k);
        $args->{$k} = $args->{$k} ? 'true' : 'false';
        delete $args->{$k} if $self->is_true_only_bool($k)
            && $args->{$k} eq 'false';
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::NormalizeBooleans - Normalize Booleans

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
