package Twitter::API::Trait::ApiMethods;
# ABSTRACT: Convenient API Methods

use 5.14.1;
use Carp;
use Moo::Role;
use MooX::Aliases;
use Ref::Util qw/is_hashref is_arrayref/;
use namespace::clean;

requires 'request';

with 'Twitter::API::Role::RequestArgs';

=method account_settings([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-account-settings>

=cut

sub account_settings {
    shift->request(get => 'account/settings', @_);
}

=method blocking([ \%args ])

Aliases: blocks_list

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/get-blocks-list>

=cut

sub blocking {
    shift->request(get => 'blocks/list', @_);
}
alias blocks_list => 'blocking';

=method blocking_ids([ \%args ])

Aliases: blocks_ids

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/get-blocks-ids>

=cut

sub blocking_ids {
    shift->request(get => 'blocks/ids', @_);
}
alias blocks_ids => 'blocking_ids';

=method collection_entries([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/get-collections-entries>

=cut

sub collection_entries {
    shift->request_with_pos_args(id => get => 'collections/entries', @_);
}

=method collections([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/get-collections-list>

=cut

sub collections {
    shift->request_with_pos_args(':ID', get => 'collections/list', @_);
}

sub direct_messages { croak 'DEPRECATED - use direct_messages_events instead' }

=method favorites([ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-favorites-list>

=cut

sub favorites {
    shift->request(get => 'favorites/list', @_);
}

=method followers([ \%args ])

Aliases: followers_list

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-followers-list>

=cut

sub followers {
    shift->request(get => 'followers/list', @_);
}
alias followers_list => 'followers';

=method followers_ids([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-followers-ids>

=cut

sub followers_ids {
    shift->request_with_pos_args(':ID', get => 'followers/ids', @_);
}

=method friends([ \%args ])

Aliases: friends_list

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friends-list>

=cut

sub friends {
    shift->request(get => 'friends/list', @_);
}
alias friends_list => 'friends';

=method friends_ids([ \%args ])

Aliases: following_ids

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friends-ids>

=cut

sub friends_ids {
    shift->request_with_id(get => 'friends/ids', @_);
}
alias following_ids => 'friends_ids';

=method friendships_incoming([ \%args ])

Aliases: incoming_friendships

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friendships-incoming>

=cut

sub friendships_incoming {
    shift->request(get => 'friendships/incoming', @_);
}
alias incoming_friendships => 'friendships_incoming';

=method friendships_outgoing([ \%args ])

Aliases: outgoing_friendships

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friendships-outgoing>

=cut

sub friendships_outgoing {
    shift->request(get => 'friendships/outgoing', @_);
}
alias outgoing_friendships => 'friendships_outgoing';

=method geo_id([ $place_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/geo/place-information/api-reference/get-geo-id-place_id>

=cut

# NT incompatibility
sub geo_id {
    shift->request_with_pos_args(place_id => get => 'geo/id/:place_id', @_);
}

=method geo_search([ \%args ])

L<https://developer.twitter.com/en/docs/geo/places-near-location/api-reference/get-geo-search>

=cut

sub geo_search {
    shift->request(get => 'geo/search', @_);
}

=method get_configuration([ \%args ])

L<https://developer.twitter.com/en/docs/developer-utilities/configuration/api-reference/get-help-configuration>

=cut

sub get_configuration {
    shift->request(get => 'help/configuration', @_);
}

=method get_languages([ \%args ])

L<https://developer.twitter.com/en/docs/developer-utilities/supported-languages/api-reference/get-help-languages>

=cut

sub get_languages {
    shift->request(get => 'help/languages', @_);
}

=method get_list([ \%args ])

Aliases: show_list

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-show>

=cut

sub get_list {
    shift->request(get => 'lists/show', @_);
}
alias show_list => 'get_list';

=method get_lists([ \%args ])

Aliases: list_lists, all_subscriptions

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-list>

=cut

sub get_lists {
    shift->request(get => 'lists/list', @_);
}
alias $_ => 'get_lists' for qw/list_lists all_subscriptions/;

=method get_privacy_policy([ \%args ])

L<https://developer.twitter.com/en/docs/developer-utilities/privacy-policy/api-reference/get-help-privacy>

=cut

sub get_privacy_policy {
    shift->request(get => 'help/privacy', @_);
}

=method get_tos([ \%args ])

L<https://developer.twitter.com/en/docs/developer-utilities/terms-of-service/api-reference/get-help-tos>

=cut

sub get_tos {
    shift->request(get => 'help/tos', @_);
}

=method home_timeline([ \%args ])

L<https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-home_timeline>

=cut

sub home_timeline {
    shift->request(get => 'statuses/home_timeline', @_);
}

=method list_members([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-members>

=cut

sub list_members {
    shift->request(get => 'lists/members', @_);
}

=method list_memberships([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-memberships>

=cut

sub list_memberships {
    shift->request(get => 'lists/memberships', @_);
}

=method list_ownerships([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-ownerships>

=cut

sub list_ownerships {
    shift->request(get => 'lists/ownerships', @_);
}

=method list_statuses([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-statuses>

=cut

sub list_statuses {
    shift->request(get => 'lists/statuses', @_);
}

=method list_subscribers([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers>

=cut

sub list_subscribers {
    shift->request(get => 'lists/subscribers', @_);
}

=method list_subscriptions([ \%args ])

Aliases: subscriptions

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-subscriptions>

=cut

sub list_subscriptions {
    shift->request(get => 'lists/subscriptions', @_);
}
alias subscriptions => 'list_subscriptions';

=method lookup_friendships([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friendships-lookup>

=cut

sub lookup_friendships {
    shift->request(get => 'friendships/lookup', @_);
}

=method lookup_statuses([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-lookup>

=cut

sub lookup_statuses {
    shift->request_with_pos_args(id => get => 'statuses/lookup', @_);
}

=method lookup_users([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup>

=cut

sub lookup_users {
    shift->request(get => 'users/lookup', @_);
}

=method mentions([ \%args ])

Aliases: replies, mentions_timeline

L<https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-mentions_timeline>

=cut

sub mentions {
    shift->request(get => 'statuses/mentions_timeline', @_);
}
alias $_ => 'mentions' for qw/replies mentions_timeline/;

=method mutes([ \%args ])

Aliases: muting_ids, muted_ids

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-ids>

=cut

sub mutes {
    shift->request(get => 'mutes/users/ids', @_);
}
alias $_ => 'mutes' for qw/muting_ids muted_ids/;

=method muting([ \%args ])

Aliases: mutes_list

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-list>

=cut

sub muting {
    shift->request(get => 'mutes/users/list', @_);
}
alias mutes_list => 'muting';

=method no_retweet_ids([ \%args ])

Aliases: no_retweets_ids

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friendships-no_retweets-ids>

=cut

sub no_retweet_ids {
    shift->request(get => 'friendships/no_retweets/ids', @_);
}
alias no_retweets_ids => 'no_retweet_ids';

=method oembed([ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-oembed>

=cut

sub oembed {
    shift->request(get => 'statuses/oembed', @_);
}

=method profile_banner([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-users-profile_banner>

=cut

sub profile_banner {
    shift->request(get => 'users/profile_banner', @_);
}

=method rate_limit_status([ \%args ])

L<https://developer.twitter.com/en/docs/developer-utilities/rate-limit-status/api-reference/get-application-rate_limit_status>

=cut

sub rate_limit_status {
    shift->request(get => 'application/rate_limit_status', @_);
}

=method retweeters_ids([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-retweeters-ids>

=cut

sub retweeters_ids {
    shift->request_with_pos_args(id => get => 'statuses/retweeters/ids', @_);
}

=method retweets([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-retweets-id>

=cut

sub retweets {
    shift->request_with_pos_args(id => get => 'statuses/retweets/:id', @_);
}

=method retweets_of_me([ \%args ])

Aliases: retweeted_of_me

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-retweets_of_me>

=cut

sub retweets_of_me {
    shift->request(get => 'statuses/retweets_of_me', @_);
}
alias retweeted_of_me => 'retweets_of_me';

=method reverse_geocode([ $lat, [ $long, ]][ \%args ])

L<https://developer.twitter.com/en/docs/geo/places-near-location/api-reference/get-geo-reverse_geocode>

=cut

sub reverse_geocode {
    shift->request_with_pos_args([ qw/lat long/ ], get => 'geo/reverse_geocode', @_);
}

=method saved_searches([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-saved_searches-list>

=cut

sub saved_searches {
    shift->request(get => 'saved_searches/list', @_);
}

=method search([ $q, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/search/api-reference/get-search-tweets>

=cut

sub search {
    shift->request_with_pos_args(q => get => 'search/tweets', @_);
}

=method sent_direct_messages([ \%args ])

Aliases: direct_messages_sent

L<https://developer.twitter.com/en/docs/direct-messages/sending-and-receiving/api-reference/get-sent-message>

=cut

sub sent_direct_messages { croak 'DEPRECATED - use direct_messages_events instead' }
alias direct_messages_sent => 'sent_direct_messages';

sub show_direct_message { croak 'DEPRECATED - show_direct_messages_event instead' }

=method show_friendship([ \%args ])

Aliases: show_relationship

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show>

=cut

sub show_friendship {
    shift->request(get => 'friendships/show', @_);
}
alias show_relationship => 'show_friendship';

=method show_list_member([ \%args ])

Aliases: is_list_member

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-members-show>

=cut

sub show_list_member {
    shift->request(get => 'lists/members/show', @_);
}
alias is_list_member => 'show_list_member';

=method show_list_subscriber([ \%args ])

Aliases: is_list_subscriber, is_subscriber_lists

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers-show>

=cut

sub show_list_subscriber {
    shift->request(get => 'lists/subscribers/show', @_);
}
alias $_ => 'show_list_subscriber' for qw/is_list_subscriber is_subscriber_lists/;

=method show_saved_search([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-saved_searches-show-id>

=cut

sub show_saved_search {
    shift->request_with_pos_args(id => get => 'saved_searches/show/:id', @_);
}

=method show_status([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-show-id>

=cut

sub show_status {
    shift->request_with_pos_args(id => get => 'statuses/show/:id', @_);
}

=method show_user([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-show>

=cut

sub show_user {
    shift->request_with_pos_args(':ID', get => 'users/show', @_);
}

=method suggestion_categories([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-suggestions>

=cut

sub suggestion_categories {
    shift->request(get => 'users/suggestions', @_);
}

=method trends_available([ \%args ])

L<https://developer.twitter.com/en/docs/trends/locations-with-trending-topics/api-reference/get-trends-available>

=cut

sub trends_available {
    my ( $self, $args ) = @_;

    goto &trends_closest if exists $$args{lat} || exists $$args{long};

    shift->request(get => 'trends/available', @_);
}

=method trends_closest([ \%args ])

L<https://developer.twitter.com/en/docs/trends/locations-with-trending-topics/api-reference/get-trends-closest>

=cut

sub trends_closest {
    shift->request(get => 'trends/closest', @_);
}

=method trends_place([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/trends/trends-for-location/api-reference/get-trends-place>

=cut

sub trends_place {
    shift->request_with_pos_args(id => get => 'trends/place', @_);
}
alias trends_location => 'trends_place';

=method user_suggestions([ $slug, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-suggestions-slug-members>

=cut

# Net::Twitter compatibility - rename category to slug
my $rename_category = sub {
    my $self = shift;

    my $args = is_hashref($_[-1]) ? pop : {};
    $args->{slug} = delete $args->{category} if exists $args->{category};
    return ( @_, $args );
};

sub user_suggestions {
    my $self = shift;

    $self->request_with_pos_args(slug => get => 'users/suggestions/:slug/members',
        $self->$rename_category(@_));
}
alias follow_suggestions => 'user_suggestions';

=method user_suggestions_for([ $slug, ][ \%args ])

Aliases: follow_suggestions

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-suggestions-slug>

=cut

sub user_suggestions_for {
    my $self = shift;

    $self->request_with_pos_args(slug => get => 'users/suggestions/:slug',
        $self->$rename_category(@_));
}
alias follow_suggestions_for => 'user_suggestions_for';

=method user_timeline([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-user_timeline>

=cut

sub user_timeline {
    shift->request_with_id(get => 'statuses/user_timeline', @_);
}

=method users_search([ $q, ][ \%args ])

Aliases: find_people, search_users

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-search>

=cut

sub users_search {
    shift->request_with_pos_args(q => get => 'users/search', @_);
}
alias $_ => 'users_search' for qw/find_people search_users/;

=method verify_credentials([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials>

=cut

sub verify_credentials {
    shift->request(get => 'account/verify_credentials', @_);
}

=method add_collection_entry([ $id, [ $tweet_id, ]][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-entries-add>

=cut

sub add_collection_entry {
    shift->request_with_pos_args([ qw/id tweet_id /],
        post => 'collections/entries/add', @_);
}

=method add_list_member([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-members-create>

=cut

sub add_list_member {
    shift->request(post => 'lists/members/create', @_);
}

# deprecated: https://dev.twitter.com/rest/reference/post/geo/place
sub add_place {
    shift->request_with_pos_args([ qw/name contained_within token lat long/ ],
        post => 'geo/place', @_);
}

=method create_block([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/post-blocks-create>

=cut

sub create_block {
    shift->request_with_pos_args(':ID', post => 'blocks/create', @_);
}

=method create_collection([ $name, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-create>

=cut

sub create_collection {
    shift->request_with_pos_args(name => post => 'collections/create', @_);
}

=method create_favorite([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-favorites-create>

=cut

sub create_favorite {
    shift->request_with_pos_args(id => post => 'favorites/create', @_);
}

=method create_friend([ $screen_name | $user_id, ][ \%args ])

Aliases: follow, follow_new, create_friendship

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create>

=cut

sub create_friend {
    shift->request_with_pos_args(':ID', post => 'friendships/create', @_);
}
alias $_ => 'create_friend' for qw/follow follow_new create_friendship/;

=method create_list([ $name, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-create>

=cut

sub create_list {
    shift->request_with_pos_args(name => post => 'lists/create', @_);
}

=method create_media_metadata([ \%args ])

L<https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-metadata-create>

=cut

# E.g.:
# create_media_metadata({ media_id => $id, alt_text => { text => $text } })
sub create_media_metadata {
    my ( $self, $to_json ) = @_;

    croak 'expected a single hashref argument'
        unless @_ == 2 && is_hashref($_[1]);

    $self->request(post => 'media/metadata/create', {
        -to_json => $to_json,
    });
}

=method create_mute([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-create>

Alias: mute

=cut

sub create_mute {
    shift->request_with_pos_args(':ID' => post => 'mutes/users/create', @_);
}
alias mute => 'create_mute';

=method create_saved_search([ $query, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-saved_searches-create>

=cut

sub create_saved_search {
    shift->request_with_pos_args(query => post => 'saved_searches/create', @_);
}

=method curate_collection([ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-entries-curate>

=cut

sub curate_collection {
    my ( $self, $to_json ) = @_;

    croak 'unexpected extra args' if @_ > 2;
    $self->request(post => 'collections/entries/curate', {
        -to_json => $to_json,
    });
}

=method delete_list([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-destroy>

=cut

sub delete_list {
    shift->request(post => 'lists/destroy', @_);
}

=method delete_list_member([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-members-destroy>

=cut

sub delete_list_member {
    shift->request(post => 'lists/members/destroy', @_);
}
alias remove_list_member => 'delete_list_member';

=method destroy_block([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/post-blocks-destroy>

=cut

sub destroy_block {
    shift->request_with_pos_args(':ID', post => 'blocks/destroy', @_);
}

=method destroy_collection([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-destroy>

=cut

sub destroy_collection {
    shift->request_with_pos_args(id => post => 'collections/destroy', @_);
}

sub destroy_direct_message { croak 'DEPRECATED - use destroy_direct_messages_event instead' }

=method destroy_favorite([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-favorites-destroy>

=cut

sub destroy_favorite {
    shift->request_with_pos_args(id => post => 'favorites/destroy', @_);
}

=method destroy_friend([ $screen_name | $user_id, ][ \%args ])

Aliases: unfollow, destroy_friendship

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/post-friendships-destroy>

=cut

sub destroy_friend {
    shift->request_with_pos_args(':ID', post => 'friendships/destroy', @_);
}
alias $_ => 'destroy_friend' for qw/unfollow destroy_friendship/;

=method destroy_mute([ $screen_name | $user_id, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-destroy>

Alias: unmute

=cut

sub destroy_mute {
    shift->request_with_pos_args(':ID' => post => 'mutes/users/destroy', @_);
}
alias unmute => 'destroy_mute';

=method destroy_saved_search([ $id, ][ \%args ])

Aliases: delete_saved_search

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-saved_searches-destroy-id>

=cut

sub destroy_saved_search {
    shift->request_with_pos_args(id => post => 'saved_searches/destroy/:id', @_);
}
alias delete_saved_search => 'destroy_saved_search';

=method destroy_status([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-destroy-id>

=cut

sub destroy_status {
    shift->request_with_pos_args(id => post => 'statuses/destroy/:id', @_);
}

=method members_create_all([ \%args ])

Aliases: add_list_members

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-members-create_all>

=cut

sub members_create_all {
    shift->request(post => 'lists/members/create_all', @_);
}
alias add_list_members => 'members_create_all';

=method members_destroy_all([ \%args ])

Aliases: remove_list_members

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-members-destroy_all>

=cut

sub members_destroy_all {
    shift->request(post => 'lists/members/destroy_all', @_);
}
alias remove_list_members => 'members_destroy_all';

=method move_collection_entry([ $id, [ $tweet_id, [ $relative_to, ]]][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-entries-move>

=cut

sub move_collection_entry {
    shift->request_with_pos_args([ qw/id tweet_id relative_to /],
        post => 'collections/entries/move', @_);
}

sub new_direct_message { croak 'DEPRECATED - use new_direct_messages_event instead' }

=method remove_collection_entry([ $id, [ $tweet_id, ]][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-entries-remove>

=cut

sub remove_collection_entry {
    shift->request_with_pos_args([ qw/id tweet_id/ ],
        post => 'collections/entries/remove', @_);
}

=method remove_profile_banner([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-remove_profile_banner>

=cut

sub remove_profile_banner {
    shift->request(post => 'account/remove_profile_banner', @_);
}

=method report_spam([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/mute-block-report-users/api-reference/post-users-report_spam>

=cut

sub report_spam {
    shift->request_with_id(post => 'users/report_spam', @_);
}

=method retweet([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-retweet-id>

=cut

sub retweet {
    shift->request_with_pos_args(id => post => 'statuses/retweet/:id', @_);
}

=method subscribe_list([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-create>

=cut

sub subscribe_list {
    shift->request(post => 'lists/subscribers/create', @_);
}

=method unretweet([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-unretweet-id>

=cut

sub unretweet {
    shift->request_with_pos_args(id => post => 'statuses/unretweet/:id', @_);
}

=method unsubscribe_list([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-destroy>

=cut

sub unsubscribe_list {
    shift->request(post => 'lists/subscribers/destroy', @_);
}

=method update([ $status, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-update>

=cut

sub update {
    my $self = shift;

    my ( $http_method, $path, $args, @rest ) =
        $self->normalize_pos_args(status => post => 'statuses/update', @_);

    $self->flatten_list_args(media_ids => $args);
    return $self->request($http_method, $path, $args, @rest);
}

=method update_account_settings([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-settings>

=cut

sub update_account_settings {
    shift->request(post => 'account/settings', @_);
}

=method update_collection([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/tweets/curate-a-collection/api-reference/post-collections-update>

=cut

sub update_collection {
    shift->request_with_pos_args(id => post => 'collections/update', @_);
}

=method update_friendship([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/post-friendships-update>

=cut

sub update_friendship {
    shift->request_with_id(post => 'friendships/update', @_);
}

=method update_list([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/create-manage-lists/api-reference/post-lists-update>

=cut

sub update_list {
    shift->request(post => 'lists/update', @_);
}

=method update_profile([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile>

=cut

sub update_profile {
    shift->request(post => 'account/update_profile', @_);
}

=method update_profile_background_image([ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_background_image>

=cut

sub update_profile_background_image {
    shift->request(post => 'account/update_profile_background_image', @_);
}

=method update_profile_banner([ $banner, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_banner>

=cut

sub update_profile_banner {
    shift->request_with_pos_args(banner => post => 'account/update_profile_banner', @_);
}

=method update_profile_image([ $image, ][ \%args ])

L<https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_image>

=cut

sub update_profile_image {
    shift->request_with_pos_args(image => post => 'account/update_profile_image', @_);
}

=method upload_media([ $media, ][ \%args ])

Aliases: upload

L<https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload>

=cut

sub upload_media {
    my $self = shift;

    # Used to require media. Now requires media *or* media_data.
    # Handle either as a positional parameter, like we do with
    # screen_name or user_id on other methods.
    if ( @_ && !is_hashref($_[0]) ) {
        my $media = shift;
        my $key = is_arrayref($media) ? 'media' : 'media_data';
        my $args = @_ && is_hashref($_[0]) ? pop : {};
        $args->{$key} = $media;
        unshift @_, $args;
    }

    my $args = shift;
    $args->{-multipart_form_data} = 1;
    $self->flatten_list_args(additional_owners => $args);

    $self->request(post => $self->upload_url_for('media/upload'), $args, @_);
}
alias upload => 'upload_media';

=method direct_messages_events([ \%args ])

L<https://developer.twitter.com/en/docs/direct-messages/sending-and-receiving/api-reference/list-events.html>

=cut

sub direct_messages_events {
    shift->request(get => 'direct_messages/events/list', @_);
}

=method show_direct_messages_event([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/direct-messages/sending-and-receiving/api-reference/get-event>

=cut

sub show_direct_messages_event {
    shift->request_with_pos_args(id => get => 'direct_messages/events/show', @_);
}

=method destroy_direct_messages_event([ $id, ][ \%args ])

L<https://developer.twitter.com/en/docs/direct-messages/sending-and-receiving/api-reference/delete-message-event>

=cut

sub destroy_direct_messages_event {
    shift->request_with_pos_args(id => delete => 'direct_messages/events/destroy', @_);
}

=method new_direct_messages_event([$text, $recipient_id ] | [ \%event ], [ \%args ])

For simple usage, pass text and recipient ID:

    $client->new_dirrect_messages_event($text, $recipient_id)

For more complex messages, pass a full event structure, for example:

    $client->new_direct_massages_event({
        type => 'message_create',
        message_create => {
            target => { recipient_id => $user_id },
            message_data => {
                text => $text,
                attachment => {
                    type  => 'media',
                    media => { id => $media->{id} },
                },
            },
        },
    })

L<https://developer.twitter.com/en/docs/direct-messages/sending-and-receiving/api-reference/new-message>

=cut

sub new_direct_messages_event {
    my $self = shift;

    # The first argument is either an event hashref, or we'll create one with
    # the first two arguments: text and recipient_id.
    my $event = ref $_[0] ? shift : {
        type => 'message_create',
        message_create => {
            message_data => { text => shift },
            target => { recipient_id => shift },
        },
    };

    # only synthetic args are appropriate, here, e.g.
    # { -token => '...', -token_secret => '...' }
    my $args = shift // {};


    $self->request(post => 'direct_messages/events/new', {
        -to_json => { event => $event }, %$args
    });
}

=method invalidate_access_token([ \%args ])

Calling this method has the same effect as a user revoking access to the
application via Twitter settings. The access token/secret pair will no longer
be valid.

This method can be called with client that has been initialized with
C<access_token> and C<access_token_secret> attributes, by passing C<-token> and
C<-token_secret> parameters, or by passing C<access_token> and
C<access_token_secret> parameters.

    $client->invalidate_access_token;
    $client->invalidate_access_token({ -token => $token, -token_secret => $secret });
    $client->invalidate_access_token({
        access_token        => $token,
        access_token_secret => $secret,
    });

Twitter added this method to the API on 2018-09-20.

See
L<https://developer.twitter.com/en/docs/basics/authentication/api-reference/invalidate_access_token>

=cut

# We've already used invalidate_token for oauth2/invalidate_otkon in
# Trait::AppAuth, so we'll name this method invalidate_acccess_token to avoid
# any conflict.

sub invalidate_access_token {
    my ( $self, $args ) = @_;

    $args //= {};

    # For consistency with Twitter::API calling conventions:
    # - accept -token/-token_secret synthetic arguments
    # - or use access_token/access_token_secret attributes
    #
    # Or, allow passing access_token/access_token secrets parameters as
    # specified in Twitter's API documentation.

    my $access_token = $$args{'-token'} // $self->access_token
        // ( $$args{'-token'} = delete $$args{access_token} )
        // croak 'requires an oauth token';

    my $access_token_secret = $$args{'-token_secret'}
        // $self->access_token_secret
        // ( $$args{'-token_secret'} = delete $$args{access_token_secret} )
        // croak 'requires an oauth token secret';

    return $self->request(post => 'oauth/invalidate_token', {
        access_token        => $access_token,
        access_token_secret => $access_token_secret,
        %$args
    });
}

1;

=pod

=head1 DESCRIPTION

This trait provides convenient methods for calling API endpoints. They are
L<Net::Twitter> compatible, with the same names and calling conventions.

Refer to L<Twitter's API documentation|https://developer.twitter.com/en/docs/api-reference-index>
for details about each method's parameters.

These methods are simply shorthand forms of C<get> and C<post>.  All methods
can be called with a parameters hashref. It can be omitted for endpoints that
do not require any parameters, such as C<mentions>. For example, all of these
calls are equivalent:

    $client->mentions;
    $client->mentions({});
    $client->get('statuses/mentions_timeline');
    $client->get('statuses/mentions_timeline', {});

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
