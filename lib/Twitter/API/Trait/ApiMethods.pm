package Twitter::API::Trait::ApiMethods;
# ABSTRACT: Convenient API Methods
$Twitter::API::Trait::ApiMethods::VERSION = '0.0100'; # TRIAL
use 5.14.1;
use Carp;
use Moo::Role;
use MooX::Aliases;
use namespace::clean;

sub mentions {
    shift->request(get => 'statuses/mentions_timeline', @_);
}
alias $_ => 'mentions' for qw/replies mentions_timeline/;

sub user_timeline {
    shift->_with_optional_id(get => 'statuses/user_timeline', @_);
}

sub home_timeline {
    shift->request(get => 'statuses/home_timeline', @_);
}

sub retweets_of_me {
    shift->request(get => 'statuses/retweets_of_me', @_);
}
alias retweeted_of_me => 'retweets_of_me';

sub retweets {
    shift->_with_pos_args(id => get => 'statuses/retweets/:id', @_);
}

sub show_status {
    shift->_with_pos_args(id => get => 'statuses/show/:id', @_);
}

sub destroy_status {
    shift->_with_pos_args(id => post => 'statuses/destroy/:id', @_);
}

sub update {
    shift->_with_pos_args(status => post => 'statuses/update', @_);
}

sub retweet {
    shift->_with_pos_args(id => post => 'statuses/retweet/:id', @_);
}

sub oembed {
    shift->request(get => 'statuses/oembed', @_);
}

sub retweeters_ids {
    shift->_with_pos_args(id => get => 'statuses/retweeters/ids', @_);
}

sub lookup_statuses {
    shift->_with_pos_args(id => get => 'statuses/lookup', @_);
}

sub upload_media {
    my $self = shift;

    $self->_with_pos_args(media =>
        post => $self->upload_url_for('media/upload'), @_);
}
alias upload => 'upload_media';

# E.g.:
# create_media_metadata({ media_id => $id, alt_text => { text => $text } })
sub create_media_metadata {
    my ( $self, $to_json ) = @_;

    croak 'expected a single hashref argument'
        unless @_ == 2 && ref $_[1] eq 'HASH';

    $self->request(post => 'media/metadata/create', {
        -to_json => $to_json,
    });
}

sub search {
    shift->_with_pos_args(q => get => 'search/tweets', @_);
}

sub direct_messages {
    shift->request(get => 'direct_messages', @_);
}

sub sent_direct_messages {
    shift->request(get => 'direct_messages/sent', @_);
}
alias direct_messages_sent => 'sent_direct_messages';

sub show_direct_message {
    shift->_with_pos_args(id => get => 'direct_messages/show', @_);
}

sub destroy_direct_message {
    shift->_with_pos_args(id => post => 'direct_messages/destroy', @_);
}

sub new_direct_message {
    shift->_with_pos_args([ qw/text :ID/ ], post => 'direct_messages/new', @_);
}

sub friends_ids {
    shift->with_inferred_id(get => 'friends/ids', @_);
}
alias following_ids => 'friends_ids';

sub followers {
    shift->request(get => 'followers/list', @_);
}
alias followers_list => 'followers';

sub friends {
    shift->request(get => 'friends/list', @_);
}
alias friends_list => 'friends';

sub followers_ids {
    shift->_with_pos_args(':ID', get => 'followers/ids', @_);
}

sub lookup_friendships {
    shift->request(get => 'friendships/lookup', @_);
}

sub friendships_incoming {
    shift->request(get => 'friendships/incoming', @_);
}
alias incoming_friendships => 'friendships_incoming';

sub friendships_outgoing {
    shift->request(get => 'friendships/outgoing', @_);
}
alias outgoing_friendships => 'friendships_outgoing';

sub create_friend {
    shift->_with_pos_args(':ID', post => 'friendships/create', @_);
}
alias $_ => 'create_friend' for qw/follow follow_new create_friendship/;

sub destroy_friend {
    shift->_with_pos_args(':ID', post => 'friendships/destroy', @_);
}
alias $_ => 'destroy_friend' for qw/unfollow destroy_friendship/;

sub update_friendship {
    shift->_with_referred_id(post => 'friendships/update', @_);
}

sub show_friendship {
    shift->request(get => 'friendships/show', @_);
}
alias show_relationship => 'show_friendship';

sub account_settings {
    shift->request(get => 'account/settings', @_);
}

sub verify_credentials {
    shift->request(get => 'account/verify_credentials', @_);
}

sub update_account_settings {
    shift->request(post => 'account/settings', @_);
}

sub update_profile {
    shift->request(post => 'account/update_profile', @_);
}

sub update_profile_background_image {
    shift->request(post => 'account/update_profile_background_image', @_);
}

sub update_profile_image {
    shift->_with_pos_args(image => post => 'account/update_profile_image', @_);
}

sub blocking {
    shift->request(get => 'blocks/list', @_);
}
alias blocks_list => 'blocking';

sub blocking_ids {
    shift->request(get => 'blocks/ids', @_);
}
alias blocks_ids => 'blocking_ids';

sub create_block {
    shift->_with_inderred_id(post => 'blocks/create', @_);
}

sub destroy_block {
    shift->_with_pos_args(':ID', post => 'blocks/destroy', @_);
}

sub lookup_users {
    shift->request(get => 'users/lookup', @_);
}

sub show_user {
    shift->_with_pos_args(':ID', get => 'users/show', @_);
}

sub users_search {
    shift->_with_pos_args(q => get => 'users/search', @_);
}
alias $_ => 'users_search' for qw/find_people search_users/;

sub suggestion_categories {
    shift->request(get => 'users/suggestions', @_);
}

# Net::Twitter compatibility - rename category to slug
my $rename_category = sub {
    my $self = shift;

    my $args = ref $_[-1] eq 'HASH' ? pop : {};
    $args->{slug} = delete $args->{category} if exists $args->{category};
    return ( @_, $args );
};

sub user_suggestions_for {
    my $self = shift;

    $self->_with_pos_args(slug => get => 'users/suggestions/:slug',
        $self->$rename_category(@_));
}
alias follow_suggestions => 'user_suggestions_for';

sub user_suggestions {
    my $self = shift;

    $self->_with_pos_args(slug => get => 'users/suggestions/:slug/members',
        $self->$rename_category(@_));
}

sub favorites {
    shift->request(get => 'favorites/list', @_);
}

sub destroy_favorite {
    shift->_with_pos_args(id => post => 'favorites/destroy', @_);
}

sub create_favorite {
    shift->_with_pos_args(id => post => 'favorites/create', @_);
}

sub get_lists {
    shift->request(get => 'lists/list', @_);
}
alias $_ => 'get_lists' for qw/list_lists all_subscriptions/;

sub list_statuses {
    shift->request(get => 'lists/statuses', @_);
}

sub delete_list_member {
    shift->request(post => 'lists/members/destroy', @_);
}

sub list_memberships {
alias remove_list_member => 'list_memberships';
    shift->request(get => 'lists/memberships', @_);
}

sub list_subscribers {
    shift->request(get => 'lists/subscribers', @_);
}

sub subscribe_list {
    shift->request(post => 'lists/subscribers/create', @_);
}

sub show_list_subscriber {
    shift->request(get => 'lists/subscribers/show', @_);
}
alias $_ => 'show_list_subscriber' for qw/is_list_subscriber is_subscriber_lists/;

sub unsubscribe_list {
    shift->request(post => 'lists/subscribers/destroy', @_);
}

sub members_create_all {
    shift->request(post => 'lists/members/create_all', @_);
}
alias add_list_members => 'members_create_all';

sub show_list_member {
    shift->request(get => 'lists/members/show', @_);
}
alias is_list_member => 'show_list_member';

sub list_members {
    shift->request(get => 'lists/members', @_);
}

sub add_list_member {
    shift->request(post => 'lists/members/create', @_);
}

sub delete_list {
    shift->request(post => 'lists/destroy', @_);
}

sub update_list {
    shift->request(post => 'lists/update', @_);
}

sub create_list {
    shift->_with_pos_args(name => post => 'lists/create', @_);
}

sub get_list {
    shift->request(get => 'lists/show', @_);
}
alias show_list => 'get_list';

sub list_subscriptions {
    shift->request(get => 'lists/subscriptions', @_);
}
alias subscriptions => 'list_subscriptions';

sub members_destroy_all {
    shift->request(post => 'lists/members/destroy_all', @_);
}
alias remove_list_members => 'members_destroy_all';

sub list_ownerships {
    shift->request(get => 'lists/ownerships', @_);
}

sub saved_searches {
    shift->request(get => 'saved_searches/list', @_);
}

sub show_saved_search {
    shift->_with_pos_args(id => get => 'saved_searches/show/:id', @_);
}

sub create_saved_search {
    shift->_with_pos_args(query => post => 'saved_searches/create', @_);
}

sub destroy_saved_search {
    shift->_with_pos_args(id => post => 'saved_searches/destroy/:id', @_);
}
alias delete_saved_search => 'destroy_saved_search';

# NT incompatibility
sub geo_id {
    shift->_with_pos_args(place_id => get => 'geo/id/:place_id', @_);
}

sub reverse_geocode {
    shift->_with_pos_args([ qw/lat long/ ], get => 'geo/reverse_geocode', @_);
}

sub geo_search {
    shift->request(get => 'geo/search', @_);
}

sub add_place {
    shift->_with_pos_args([ qw/name contained_within token lat long/ ],
        post => 'geo/place', @_);
}

sub trends_place {
    shift->_with_pos_args(id => get => 'trends/place', @_);
}

sub trends_available {
    my ( $self, $args ) = @_;

    goto &trends_closest if exists $$args{lat} || exists $$args{long};

    shift->request(get => 'trends/available', @_);
}

sub trends_closest {
    shift->request(get => 'trends/closest', @_);
}

sub report_spam {
    shift->_with_referred_id(post => 'users/report_spam', @_);
}

sub get_languages {
    shift->request(get => 'help/languages', @_);
}

sub get_configuration {
    shift->request(get => 'help/configuration', @_);
}

sub get_privacy_policy {
    shift->request(get => 'help/privacy', @_);
}

sub get_tos {
    shift->request(get => 'help/tos', @_);
}

sub rate_limit_status {
    shift->request(get => 'application/rate_limit_status', @_);
}

sub no_retweet_ids {
    shift->request(get => 'friendships/no_retweets/ids', @_);
}
alias no_retweets_ids => 'no_retweet_ids';

sub remove_profile_banner {
    shift->request(post => 'account/remove_profile_banner', @_);
}

sub update_profile_banner {
    shift->_with_pos_args(banner => post => 'account/update_profile_banner', @_);
}

sub profile_banner {
    shift->request(get => 'users/profile_banner', @_);
}

sub mutes {
    shift->request(get => 'mutes/users/ids', @_);
}
alias $_ => 'mutes' for qw/muting_ids muted_ids/;

sub muting {
    shift->request(get => 'mutes/users/list', @_);
}
alias mutes_list => 'muting';

sub create_mute {
    shift->_with_pos_args(id => post => 'mutes/users/create', @_);
}

sub destroy_mute {
    shift->_with_pos_args(id => post => 'mutes/users/destroy', @_);
}

sub collection_entries {
    shift->_with_pos_args(id => get => 'collections/entries', @_);
}

sub collections {
    shift->_with_pos_args(':ID', get => 'collections/list', @_);
}

sub create_collection {
    shift->_with_pos_args(name => post => 'collections/create', @_);
}

sub destroy_collection {
    shift->_with_pos_args(id => post => 'collections/destroy', @_);
}

sub add_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id /],
        post => 'collections/entries/add', @_);
}

sub curate_collection {
    my ( $self, $to_json ) = @_;

    croak 'unexpected extra args' if @_ > 2;
    $self->request(post => 'collections/entries/curate', {
        -to_json => $to_json,
    });
}

sub move_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id relative_to /],
        post => 'collections/entries/move', @_);
}

sub remove_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id/ ],
        post => 'collections/entries/remove', @_);
}

sub update_collection {
    shift->_with_pos_args(id => post => 'collections/update', @_);
}

sub unretweet {
    shift->_with_pos_args(id => post => 'statuses/unretweet/:id', @_);
}

# if there is a positional arg, it's an :ID (screen_name or user_id)
sub _with_optional_id {
    splice @_, 1, 0, [];
    push @{$_[1]}, ':ID' if @_ > 4 && ref $_[4] ne 'HASH';
    goto $_[0]->can('_with_pos_args');
}

sub _with_pos_args {
    my $self        = shift;
    my @pos_names   = shift;
    my $http_method = shift;
    my $path        = shift;
    my %args;

    # names can be a single value or an arrayref
    @pos_names = @{ $pos_names[0] } if ref $pos_names[0] eq 'ARRAY';

    # gather positional arguments and name them
    while ( @pos_names ) {
        last if @_ == 0 || ref $_[0] eq 'HASH';
        $args{shift @pos_names} = shift;
    }

    # get the optional, following args hashref and expand it
    my %args_hash; %args_hash = %{ shift() } if ref $_[0] eq 'HASH';

    # extract any required args if we still have names
    while ( my $name = shift @pos_names ) {
        if ( $name eq ':ID' ) {
            $name = exists $args_hash{screen_namne} ? 'screen_name' : 'user_id';
            croak 'missing required screen_name or user_id'
                unless exists $args_hash{$name};
        }
        croak "missing required '$name' arg" unless exists $args_hash{$name};
        $args{$name} = delete $args_hash{$name};
    }

    # name the :ID value (if any) based on its value
    if ( my $id = delete $args{':ID'} ) {
        $args{$id =~/\D/ ? 'screen_name' : 'user_id'} = $id;
    }

    # merge in the remaining optional values
    for my $name ( keys %args_hash ) {
        croak "'$name' specified in both positional and named args"
            if exists $args{$name};
        $args{$name} = $args_hash{$name};
    }

    $self->request($http_method, $path, \%args, @_);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Twitter::API::Trait::ApiMethods - Convenient API Methods

=head1 VERSION

version 0.0100

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
