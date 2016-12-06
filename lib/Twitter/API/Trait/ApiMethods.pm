package Twitter::API::Trait::ApiMethods;
# ABSTRACT: Convenient API Methods

use 5.14.1;
use Carp;
use Moo::Role;
use MooX::Aliases;
use namespace::clean;

=method account_settings([ \%args ])

L<https://dev.twitter.com/rest/reference/get/account/settings>

=cut

sub account_settings {
    shift->request(get => 'account/settings', @_);
}

=method blocking([ \%args ])

Aliases: blocks_list

L<https://dev.twitter.com/rest/reference/get/blocks/list>

=cut

sub blocking {
    shift->request(get => 'blocks/list', @_);
}
alias blocks_list => 'blocking';

=method blocking_ids([ \%args ])

Aliases: blocks_ids

L<https://dev.twitter.com/rest/reference/get/blocks/ids>

=cut

sub blocking_ids {
    shift->request(get => 'blocks/ids', @_);
}
alias blocks_ids => 'blocking_ids';

=method collection_entries([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/collections/entries>

=cut

sub collection_entries {
    shift->_with_pos_args(id => get => 'collections/entries', @_);
}

=method collections([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/collections/list>

=cut

sub collections {
    shift->_with_pos_args(':ID', get => 'collections/list', @_);
}

=method direct_messages([ \%args ])

L<https://dev.twitter.com/rest/reference/get/direct_messages>

=cut

sub direct_messages {
    shift->request(get => 'direct_messages', @_);
}

=method favorites([ \%args ])

L<https://dev.twitter.com/rest/reference/get/favorites/list>

=cut

sub favorites {
    shift->request(get => 'favorites/list', @_);
}

=method followers([ \%args ])

Aliases: followers_list

L<https://dev.twitter.com/rest/reference/get/followers/list>

=cut

sub followers {
    shift->request(get => 'followers/list', @_);
}
alias followers_list => 'followers';

=method followers_ids([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/followers/ids>

=cut

sub followers_ids {
    shift->_with_pos_args(':ID', get => 'followers/ids', @_);
}

=method friends([ \%args ])

Aliases: friends_list

L<https://dev.twitter.com/rest/reference/get/friends/list>

=cut

sub friends {
    shift->request(get => 'friends/list', @_);
}
alias friends_list => 'friends';

=method friends_ids([ \%args ])

Aliases: following_ids

L<https://dev.twitter.com/rest/reference/get/friends/ids>

=cut

sub friends_ids {
    shift->_with_optional_id(get => 'friends/ids', @_);
}
alias following_ids => 'friends_ids';

=method friendships_incoming([ \%args ])

Aliases: incoming_friendships

L<https://dev.twitter.com/rest/reference/get/friendships/incoming>

=cut

sub friendships_incoming {
    shift->request(get => 'friendships/incoming', @_);
}
alias incoming_friendships => 'friendships_incoming';

=method friendships_outgoing([ \%args ])

Aliases: outgoing_friendships

L<https://dev.twitter.com/rest/reference/get/friendships/outgoing>

=cut

sub friendships_outgoing {
    shift->request(get => 'friendships/outgoing', @_);
}
alias outgoing_friendships => 'friendships_outgoing';

=method geo_id([ $place_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/geo/id/:place_id>

=cut

# NT incompatibility
sub geo_id {
    shift->_with_pos_args(place_id => get => 'geo/id/:place_id', @_);
}

=method geo_search([ \%args ])

L<https://dev.twitter.com/rest/reference/get/geo/search>

=cut

sub geo_search {
    shift->request(get => 'geo/search', @_);
}

=method get_configuration([ \%args ])

L<https://dev.twitter.com/rest/reference/get/help/configuration>

=cut

sub get_configuration {
    shift->request(get => 'help/configuration', @_);
}

=method get_languages([ \%args ])

L<https://dev.twitter.com/rest/reference/get/help/languages>

=cut

sub get_languages {
    shift->request(get => 'help/languages', @_);
}

=method get_list([ \%args ])

Aliases: show_list

L<https://dev.twitter.com/rest/reference/get/lists/show>

=cut

sub get_list {
    shift->request(get => 'lists/show', @_);
}
alias show_list => 'get_list';

=method get_lists([ \%args ])

Aliases: list_lists, all_subscriptions

L<https://dev.twitter.com/rest/reference/get/lists/list>

=cut

sub get_lists {
    shift->request(get => 'lists/list', @_);
}
alias $_ => 'get_lists' for qw/list_lists all_subscriptions/;

=method get_privacy_policy([ \%args ])

L<https://dev.twitter.com/rest/reference/get/help/privacy>

=cut

sub get_privacy_policy {
    shift->request(get => 'help/privacy', @_);
}

=method get_tos([ \%args ])

L<https://dev.twitter.com/rest/reference/get/help/tos>

=cut

sub get_tos {
    shift->request(get => 'help/tos', @_);
}

=method home_timeline([ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/home_timeline>

=cut

sub home_timeline {
    shift->request(get => 'statuses/home_timeline', @_);
}

=method list_members([ \%args ])

L<https://dev.twitter.com/rest/reference/get/lists/members>

=cut

sub list_members {
    shift->request(get => 'lists/members', @_);
}

=method list_memberships([ \%args ])

L<https://dev.twitter.com/rest/reference/get/lists/memberships>

=cut

sub list_memberships {
    shift->request(get => 'lists/memberships', @_);
}

=method list_ownerships([ \%args ])

L<https://dev.twitter.com/rest/reference/get/lists/ownerships>

=cut

sub list_ownerships {
    shift->request(get => 'lists/ownerships', @_);
}

=method list_statuses([ \%args ])

L<https://dev.twitter.com/rest/reference/get/lists/statuses>

=cut

sub list_statuses {
    shift->request(get => 'lists/statuses', @_);
}

=method list_subscribers([ \%args ])

L<https://dev.twitter.com/rest/reference/get/lists/subscribers>

=cut

sub list_subscribers {
    shift->request(get => 'lists/subscribers', @_);
}

=method list_subscriptions([ \%args ])

Aliases: subscriptions

L<https://dev.twitter.com/rest/reference/get/lists/subscriptions>

=cut

sub list_subscriptions {
    shift->request(get => 'lists/subscriptions', @_);
}
alias subscriptions => 'list_subscriptions';

=method lookup_friendships([ \%args ])

L<https://dev.twitter.com/rest/reference/get/friendships/lookup>

=cut

sub lookup_friendships {
    shift->request(get => 'friendships/lookup', @_);
}

=method lookup_statuses([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/lookup>

=cut

sub lookup_statuses {
    shift->_with_pos_args(id => get => 'statuses/lookup', @_);
}

=method lookup_users([ \%args ])

L<https://dev.twitter.com/rest/reference/get/users/lookup>

=cut

sub lookup_users {
    shift->request(get => 'users/lookup', @_);
}

=method mentions([ \%args ])

Aliases: replies, mentions_timeline

L<https://dev.twitter.com/rest/reference/get/statuses/mentions_timeline>

=cut

sub mentions {
    shift->request(get => 'statuses/mentions_timeline', @_);
}
alias $_ => 'mentions' for qw/replies mentions_timeline/;

=method mutes([ \%args ])

Aliases: muting_ids, muted_ids

L<https://dev.twitter.com/rest/reference/get/mutes/users/ids>

=cut

sub mutes {
    shift->request(get => 'mutes/users/ids', @_);
}
alias $_ => 'mutes' for qw/muting_ids muted_ids/;

=method muting([ \%args ])

Aliases: mutes_list

L<https://dev.twitter.com/rest/reference/get/mutes/users/list>

=cut

sub muting {
    shift->request(get => 'mutes/users/list', @_);
}
alias mutes_list => 'muting';

=method no_retweet_ids([ \%args ])

Aliases: no_retweets_ids

L<https://dev.twitter.com/rest/reference/get/friendships/no_retweets/ids>

=cut

sub no_retweet_ids {
    shift->request(get => 'friendships/no_retweets/ids', @_);
}
alias no_retweets_ids => 'no_retweet_ids';

=method oembed([ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/oembed>

=cut

sub oembed {
    shift->request(get => 'statuses/oembed', @_);
}

=method profile_banner([ \%args ])

L<https://dev.twitter.com/rest/reference/get/users/profile_banner>

=cut

sub profile_banner {
    shift->request(get => 'users/profile_banner', @_);
}

=method rate_limit_status([ \%args ])

L<https://dev.twitter.com/rest/reference/get/application/rate_limit_status>

=cut

sub rate_limit_status {
    shift->request(get => 'application/rate_limit_status', @_);
}

=method retweeters_ids([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/retweeters/ids>

=cut

sub retweeters_ids {
    shift->_with_pos_args(id => get => 'statuses/retweeters/ids', @_);
}

=method retweets([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/retweets/:id>

=cut

sub retweets {
    shift->_with_pos_args(id => get => 'statuses/retweets/:id', @_);
}

=method retweets_of_me([ \%args ])

Aliases: retweeted_of_me

L<https://dev.twitter.com/rest/reference/get/statuses/retweets_of_me>

=cut

sub retweets_of_me {
    shift->request(get => 'statuses/retweets_of_me', @_);
}
alias retweeted_of_me => 'retweets_of_me';

=method reverse_geocode([ $lat, [ $long, ]][ \%args ])

L<https://dev.twitter.com/rest/reference/get/geo/reverse_geocode>

=cut

sub reverse_geocode {
    shift->_with_pos_args([ qw/lat long/ ], get => 'geo/reverse_geocode', @_);
}

=method saved_searches([ \%args ])

L<https://dev.twitter.com/rest/reference/get/saved_searches/list>

=cut

sub saved_searches {
    shift->request(get => 'saved_searches/list', @_);
}

=method search([ $q, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/search/tweets>

=cut

sub search {
    shift->_with_pos_args(q => get => 'search/tweets', @_);
}

=method sent_direct_messages([ \%args ])

Aliases: direct_messages_sent

L<https://dev.twitter.com/rest/reference/get/direct_messages/sent>

=cut

sub sent_direct_messages {
    shift->request(get => 'direct_messages/sent', @_);
}
alias direct_messages_sent => 'sent_direct_messages';

=method show_direct_message([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/direct_messages/show>

=cut

sub show_direct_message {
    shift->_with_pos_args(id => get => 'direct_messages/show', @_);
}

=method show_friendship([ \%args ])

Aliases: show_relationship

L<https://dev.twitter.com/rest/reference/get/friendships/show>

=cut

sub show_friendship {
    shift->request(get => 'friendships/show', @_);
}
alias show_relationship => 'show_friendship';

=method show_list_member([ \%args ])

Aliases: is_list_member

L<https://dev.twitter.com/rest/reference/get/lists/members/show>

=cut

sub show_list_member {
    shift->request(get => 'lists/members/show', @_);
}
alias is_list_member => 'show_list_member';

=method show_list_subscriber([ \%args ])

Aliases: is_list_subscriber, is_subscriber_lists

L<https://dev.twitter.com/rest/reference/get/lists/subscribers/show>

=cut

sub show_list_subscriber {
    shift->request(get => 'lists/subscribers/show', @_);
}
alias $_ => 'show_list_subscriber' for qw/is_list_subscriber is_subscriber_lists/;

=method show_saved_search([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/saved_searches/show/:id>

=cut

sub show_saved_search {
    shift->_with_pos_args(id => get => 'saved_searches/show/:id', @_);
}

=method show_status([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/show/:id>

=cut

sub show_status {
    shift->_with_pos_args(id => get => 'statuses/show/:id', @_);
}

=method show_user([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/users/show>

=cut

sub show_user {
    shift->_with_pos_args(':ID', get => 'users/show', @_);
}

=method suggestion_categories([ \%args ])

L<https://dev.twitter.com/rest/reference/get/users/suggestions>

=cut

sub suggestion_categories {
    shift->request(get => 'users/suggestions', @_);
}

=method trends_available([ \%args ])

L<https://dev.twitter.com/rest/reference/get/trends/available>

=cut

sub trends_available {
    my ( $self, $args ) = @_;

    goto &trends_closest if exists $$args{lat} || exists $$args{long};

    shift->request(get => 'trends/available', @_);
}

=method trends_closest([ \%args ])

L<https://dev.twitter.com/rest/reference/get/trends/closest>

=cut

sub trends_closest {
    shift->request(get => 'trends/closest', @_);
}

=method trends_place([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/trends/place>

=cut

sub trends_place {
    shift->_with_pos_args(id => get => 'trends/place', @_);
}
alias trends_location => 'trends_place';

=method user_suggestions([ $slug, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/users/suggestions/:slug/members>

=cut

# Net::Twitter compatibility - rename category to slug
my $rename_category = sub {
    my $self = shift;

    my $args = ref $_[-1] eq 'HASH' ? pop : {};
    $args->{slug} = delete $args->{category} if exists $args->{category};
    return ( @_, $args );
};

sub user_suggestions {
    my $self = shift;

    $self->_with_pos_args(slug => get => 'users/suggestions/:slug/members',
        $self->$rename_category(@_));
}
alias follow_suggestions => 'user_suggestions';

=method user_suggestions_for([ $slug, ][ \%args ])

Aliases: follow_suggestions

L<https://dev.twitter.com/rest/reference/get/users/suggestions/:slug>

=cut

sub user_suggestions_for {
    my $self = shift;

    $self->_with_pos_args(slug => get => 'users/suggestions/:slug',
        $self->$rename_category(@_));
}
alias follow_suggestions_for => 'user_suggestions_for';

=method user_timeline([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/get/statuses/user_timeline>

=cut

sub user_timeline {
    shift->_with_optional_id(get => 'statuses/user_timeline', @_);
}

=method users_search([ $q, ][ \%args ])

Aliases: find_people, search_users

L<https://dev.twitter.com/rest/reference/get/users/search>

=cut

sub users_search {
    shift->_with_pos_args(q => get => 'users/search', @_);
}
alias $_ => 'users_search' for qw/find_people search_users/;

=method verify_credentials([ \%args ])

L<https://dev.twitter.com/rest/reference/get/account/verify_credentials>

=cut

sub verify_credentials {
    shift->request(get => 'account/verify_credentials', @_);
}

=method add_collection_entry([ $id, [ $tweet_id, ]][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/entries/add>

=cut

sub add_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id /],
        post => 'collections/entries/add', @_);
}

=method add_list_member([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/members/create>

=cut

sub add_list_member {
    shift->request(post => 'lists/members/create', @_);
}

# deprecated: https://dev.twitter.com/rest/reference/post/geo/place
sub add_place {
    shift->_with_pos_args([ qw/name contained_within token lat long/ ],
        post => 'geo/place', @_);
}

=method create_block([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/blocks/create>

=cut

sub create_block {
    shift->_with_pos_args(':ID', post => 'blocks/create', @_);
}

=method create_collection([ $name, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/create>

=cut

sub create_collection {
    shift->_with_pos_args(name => post => 'collections/create', @_);
}

=method create_favorite([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/favorites/create>

=cut

sub create_favorite {
    shift->_with_pos_args(id => post => 'favorites/create', @_);
}

=method create_friend([ $screen_name | $user_id, ][ \%args ])

Aliases: follow, follow_new, create_friendship

L<https://dev.twitter.com/rest/reference/post/friendships/create>

=cut

sub create_friend {
    shift->_with_pos_args(':ID', post => 'friendships/create', @_);
}
alias $_ => 'create_friend' for qw/follow follow_new create_friendship/;

=method create_list([ $name, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/create>

=cut

sub create_list {
    shift->_with_pos_args(name => post => 'lists/create', @_);
}

=method create_media_metadata([ \%args ])

L<https://dev.twitter.com/rest/reference/post/media/metadata/create>

=cut

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

=method create_mute([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/mutes/users/create>

=cut

sub create_mute {
    shift->_with_pos_args(id => post => 'mutes/users/create', @_);
}

=method create_saved_search([ $query, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/saved_searches/create>

=cut

sub create_saved_search {
    shift->_with_pos_args(query => post => 'saved_searches/create', @_);
}

=method curate_collection([ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/entries/curate>

=cut

sub curate_collection {
    my ( $self, $to_json ) = @_;

    croak 'unexpected extra args' if @_ > 2;
    $self->request(post => 'collections/entries/curate', {
        -to_json => $to_json,
    });
}

=method delete_list([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/destroy>

=cut

sub delete_list {
    shift->request(post => 'lists/destroy', @_);
}

=method delete_list_member([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/members/destroy>

=cut

sub delete_list_member {
    shift->request(post => 'lists/members/destroy', @_);
}
alias remove_list_member => 'delete_list_member';

=method destroy_block([ $screen_name | $user_id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/blocks/destroy>

=cut

sub destroy_block {
    shift->_with_pos_args(':ID', post => 'blocks/destroy', @_);
}

=method destroy_collection([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/destroy>

=cut

sub destroy_collection {
    shift->_with_pos_args(id => post => 'collections/destroy', @_);
}

=method destroy_direct_message([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/direct_messages/destroy>

=cut

sub destroy_direct_message {
    shift->_with_pos_args(id => post => 'direct_messages/destroy', @_);
}

=method destroy_favorite([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/favorites/destroy>

=cut

sub destroy_favorite {
    shift->_with_pos_args(id => post => 'favorites/destroy', @_);
}

=method destroy_friend([ $screen_name | $user_id, ][ \%args ])

Aliases: unfollow, destroy_friendship

L<https://dev.twitter.com/rest/reference/post/friendships/destroy>

=cut

sub destroy_friend {
    shift->_with_pos_args(':ID', post => 'friendships/destroy', @_);
}
alias $_ => 'destroy_friend' for qw/unfollow destroy_friendship/;

=method destroy_mute([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/mutes/users/destroy>

=cut

sub destroy_mute {
    shift->_with_pos_args(id => post => 'mutes/users/destroy', @_);
}

=method destroy_saved_search([ $id, ][ \%args ])

Aliases: delete_saved_search

L<https://dev.twitter.com/rest/reference/post/saved_searches/destroy/:id>

=cut

sub destroy_saved_search {
    shift->_with_pos_args(id => post => 'saved_searches/destroy/:id', @_);
}
alias delete_saved_search => 'destroy_saved_search';

=method destroy_status([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/statuses/destroy/:id>

=cut

sub destroy_status {
    shift->_with_pos_args(id => post => 'statuses/destroy/:id', @_);
}

=method members_create_all([ \%args ])

Aliases: add_list_members

L<https://dev.twitter.com/rest/reference/post/lists/members/create_all>

=cut

sub members_create_all {
    shift->request(post => 'lists/members/create_all', @_);
}
alias add_list_members => 'members_create_all';

=method members_destroy_all([ \%args ])

Aliases: remove_list_members

L<https://dev.twitter.com/rest/reference/post/lists/members/destroy_all>

=cut

sub members_destroy_all {
    shift->request(post => 'lists/members/destroy_all', @_);
}
alias remove_list_members => 'members_destroy_all';

=method move_collection_entry([ $id, [ $tweet_id, [ $relative_to, ]]][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/entries/move>

=cut

sub move_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id relative_to /],
        post => 'collections/entries/move', @_);
}

=method new_direct_message([ $text, [ $screen_name | $user_id, ]][ \%args ])

L<https://dev.twitter.com/rest/reference/post/direct_messages/new>

=cut

sub new_direct_message {
    shift->_with_pos_args([ qw/text :ID/ ], post => 'direct_messages/new', @_);
}

=method remove_collection_entry([ $id, [ $tweet_id, ]][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/entries/remove>

=cut

sub remove_collection_entry {
    shift->_with_pos_args([ qw/id tweet_id/ ],
        post => 'collections/entries/remove', @_);
}

=method remove_profile_banner([ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/remove_profile_banner>

=cut

sub remove_profile_banner {
    shift->request(post => 'account/remove_profile_banner', @_);
}

=method report_spam([ \%args ])

L<https://dev.twitter.com/rest/reference/post/users/report_spam>

=cut

sub report_spam {
    shift->_with_optional_id(post => 'users/report_spam', @_);
}

=method retweet([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/statuses/retweet/:id>

=cut

sub retweet {
    shift->_with_pos_args(id => post => 'statuses/retweet/:id', @_);
}

=method subscribe_list([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/subscribers/create>

=cut

sub subscribe_list {
    shift->request(post => 'lists/subscribers/create', @_);
}

=method unretweet([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/statuses/unretweet/:id>

=cut

sub unretweet {
    shift->_with_pos_args(id => post => 'statuses/unretweet/:id', @_);
}

=method unsubscribe_list([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/subscribers/destroy>

=cut

sub unsubscribe_list {
    shift->request(post => 'lists/subscribers/destroy', @_);
}

=method update([ $status, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/statuses/update>

=cut

sub update {
    shift->_with_pos_args(status => post => 'statuses/update', @_);
}

=method update_account_settings([ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/settings>

=cut

sub update_account_settings {
    shift->request(post => 'account/settings', @_);
}

=method update_collection([ $id, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/collections/update>

=cut

sub update_collection {
    shift->_with_pos_args(id => post => 'collections/update', @_);
}

=method update_friendship([ \%args ])

L<https://dev.twitter.com/rest/reference/post/friendships/update>

=cut

sub update_friendship {
    shift->_with_optional_id(post => 'friendships/update', @_);
}

=method update_list([ \%args ])

L<https://dev.twitter.com/rest/reference/post/lists/update>

=cut

sub update_list {
    shift->request(post => 'lists/update', @_);
}

=method update_profile([ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/update_profile>

=cut

sub update_profile {
    shift->request(post => 'account/update_profile', @_);
}

=method update_profile_background_image([ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/update_profile_background_image>

=cut

sub update_profile_background_image {
    shift->request(post => 'account/update_profile_background_image', @_);
}

=method update_profile_banner([ $banner, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/update_profile_banner>

=cut

sub update_profile_banner {
    shift->_with_pos_args(banner => post => 'account/update_profile_banner', @_);
}

=method update_profile_image([ $image, ][ \%args ])

L<https://dev.twitter.com/rest/reference/post/account/update_profile_image>

=cut

sub update_profile_image {
    shift->_with_pos_args(image => post => 'account/update_profile_image', @_);
}

=method upload_media([ $media, ][ \%args ])

Aliases: upload

L<https://dev.twitter.com/rest/reference/post/media/upload>

=cut

sub upload_media {
    my $self = shift;

    # Used to require media. Now requires media *or* media_data.
    # Handle either as a positional parameter, like we do with
    # screen_name or user_id on other methods.
    if ( @_ && ref $_[0] ne 'HASH' ) {
        my $media = shift;
        my $key = ref $media ? 'media' : 'media_data';
        my $args = @_ && ref $_[0] eq 'HASH' ? pop : {};
        $args->{$key} = $media;
        unshift @_, $args;
    }

    my $args = shift;
    $args->{-multipart_form_data} = 1;

    # We normally only flatten arrays for GET requests, because we assume
    # arrayrefs in POST requests represent file uploads.
    if ( my $owners = delete $args->{additional_owners} ) {
        $args->{additional_owners} = join ',' => @$owners;
    }
    $self->request(post => $self->upload_url_for('media/upload'), $args, @_);
}
alias upload => 'upload_media';


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
            $name = exists $args_hash{screen_name} ? 'screen_name' : 'user_id';
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

=pod

=head1 DESCRIPTION

This trait provides convenient methods for calling API endpoints. They are
L<Net::Twitter> compatible, with the same names and calling conventions.

Refer to L<Twitter's API documentation|https://dev.twitter.com/rest/reference>
for details about each method's parameters.

These methods are simply shorthand forms of C<get> and C<post>.  All methods
can be called with a parameters hashref. It can be omitted for endpoints that
do not require any parameters, such as C<mentions>. For example, all of these
calls are equivalent:

    $client->mentions;
    $client->mentions({});
    $client->get('statuses/mentions_timeline');
    $client->get('statuses/mentions_timelien', {});

Use the parameters hashref to pass optional parameters. For example,

    $client->mentions({ count => 200, trim_user=>'true' });

Some methods, with required parameters, can take positional parameters. For
example, C<geo_id> requires a C<place_id> parameter. These calls are
equivalent:

    $client->place_id($place);
    $client->place_id({ place_id => $place });

When positional parameters are allowed, they must be specified in the correct
order, but they don't all need to be specified. Those not specified
positionally can be added to the parameters hashref. For example, these calls
are equivalent:

    $client->add_collection_entry($id, $tweet_id);
    $client->add_collection_entry($id, { tweet_id => $tweet_id);
    $client->add_collection_entry({ id => $id, tweet_id => $tweet_id });

Many calls require a C<screen_name> or C<user_id>. Where noted, you may pass
either ID as the first positional parameter. Twitter::API will inspect the
value. If it contains only digits, it will be considered a C<user_id>.
Otherwise, it will be considered a C<screen_name>. Best practice is to
explicitly declare the ID type by passing it in the parameters hashref, because
it is possible to for users to set their screen names to a string of digits,
making the inferred ID ambiguous. These calls are equivalent:

   $client->create_block('realDonaldTrump');
   $client->create_block({ screen_name => 'realDonaldTrump' });

Since all of these methods simple resolve to a C<get> or C<post> call, see the
L<Twitter::API> for details about return values and error handling.

=cut
