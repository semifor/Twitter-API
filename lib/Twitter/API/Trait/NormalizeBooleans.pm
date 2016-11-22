package Twitter::API::Trait::NormalizeBooleans;
use Moo::Role;

use 5.12.1;
use strictures 2;
use namespace::autoclean;

requires 'preprocess_args';

around preprocess_args => sub {
    my ( $next, $self, $c ) = @_;

    $self->$next($c);
    $self->normalize_bools($c->{args});
};

# Twitter usually accepts 1, 't', 'true', or false for booleans, but they
# prefer 'true' or 'false'. In some cases, like include_email, they only accept
# 'true'. So, we normalize these options.
sub boolean_args {
    qw/
        contributor_details display_coordinates exclude_replies hide_media
        hide_thread hide_tweet include_email include_entities include_my_tweet
        include_rts include_user_entities map omit_script possibly_sensitive
        reverse skip_status skip_user trim_user
    /;
}

# Workaround Twitter bug: any value passed for these options are treated as
# true.  The only way to get 'false' is to not pass the skip_user at all. So,
# we strip these boolean args if their values are false.
sub true_only_booleans { qw/skip_status skip_user/ }

sub normalize_bools {
    my ( $self, $args ) = @_;

    # Twitter prefers 'true' or 'false' (requires it in some cases).
    for my $k ( $self->boolean_args ) {
        next unless exists $args->{$k};
        next if $args->{$k} =~ /^true|false$/;
        $args->{$k} = $args->{$k} ? 'true' : 'false';
    }

    for my $k ( $self->true_only_booleans ) {
        delete $args->{$k} if exists $args->{$k} && $args->{$k} eq 'false';
    }
}

1;
