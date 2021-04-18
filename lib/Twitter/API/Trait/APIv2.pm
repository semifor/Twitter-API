package Twitter::API::Trait::APIv2;
# ABSTRACT: Twitter API V2 interface

=head1 SYNOPSIS

    use Twitter::API;

    my $v2 = Twitter::API->new_with_options(
        consumer_key    => $ENV{TWITTER_CONSUMER_KEY},
        consumer_secret => $ENV{TWITTER_CONSUMER_SECRET},
        traits => [ qw/APIv2 AppAuth RetryOnError/ ],
    );

    # get a bearer token or App Auth
    $v2->access_token($v2->oauth2_token);

    $tweets = $v2->tweets_recent_search({ query => 'perl' });
    say $_->decoded_text for @$tweets;


=head1 DESCRIPTION

This is highly experimental code and will changed substantially before release.
The Twitter API v2 is in beta, has some bugs, and may change, itself.

=cut

use Moo::Role;

# TODO: automatically require Twitter::API::V2::Repsonse::*
use Twitter::API::V2::Response::GenericTweetsTimelineResponse;
use Twitter::API::V2::Response::SingleTweetLookupResponse;
use Twitter::API::V2::Response::SingleUserLookupResponse;
use Twitter::API::V2::Response::TweetLookupResponse;
use Twitter::API::V2::Response::TweetSearchResponse;
use Twitter::API::V2::Response::UserLookupResponse;
use Twitter::API::V2::Response::UsersFollowersLookupResponse;

use namespace::clean;

has '+api_version' => (
    is      => 'ro',
    default => sub { '2' },
);

has '+api_ext' => (
    is      => 'ro',
    default => sub { '' },
);

sub api_v2_call {
    my ( $self, $method, $path, $return_type ) = splice @_, 0, 4;
    my $args = ref $_[-1] eq 'HASH' ? pop : {};

    # path-part args passed as method argumens
    while ( @_ ) {
        my $path_part = shift;
        die 'expected scalar path-part argument' if ref $path_part;

        $path =~ s/\{\w+\}/$path_part/ || die 'too many path-part aguments';
    }

    # path-part args as named args in $args
    $path =~ s|\{(\w+)\}|delete $$args{$1} // die "$1 required"|ge;

    my ( $r, $c ) = $self->request($method, $path, $args);
    if ( $return_type ) {
        my $class = 'Twitter::API::V2::Response::' . $return_type;
        $r = $class->new($r);
    }

    wantarray ? ( $r, $c ) : $r;
}

sub get_open_api_spec {
    shift->api_v2_call(get => 'openapi.json');
}

sub find_tweets_by_id {
    shift->api_v2_call(get => 'tweets', 'TweetLookupResponse', @_);
}

sub sample_stream {
    ...;
    # shift->api_v2_call(get => 'tweets/sample/stream', 'StreamingTweet', @_);
}

sub tweets_fullarchive_search {
    shift->api_v2_call(get => 'tweets/search/all', 'TweetSearchResponse', @_);
}

sub tweets_recent_search {
    shift->api_v2_call(get => 'tweets/search/recent', 'TweetSearchResponse', @_);
}

sub search_stream {
    ...;
    # shift->api_v2_call(get => 'tweets/search/stream', 'FilteredStreamingTweet', @_);
}

sub get_rules {
    ...;
    # shift->api_v2_call(get => 'tweets/search/stream/rules', '', @_);
}

sub add_or_delete_rules {
    ...;
    # shift->api_v2_call(post => 'tweets/search/stream/rules', 'AddOrDeleteRulesResponse', @_);
}

sub find_tweet_by_id {
    shift->api_v2_call(get => 'tweets/{id}', 'SingleTweetLookupResponse', @_);
}

# The spec has hide_reply_by_id taking a ( hidden => true/false ) parameter.
# We'll provide hide-reply_by_id and unhide_relpy_id taking just the ID.
sub _hide_unhide_reply_by_id {
    my ( $self, $bool ) = ( shift, shift );
    my %args = ref $_[-1] eq 'HASH' ? %{ pop() } : ();

    $args{-to_json} = { hidden => $bool };
    $self->api_v2_call(PUT => 'tweets/{id}/hidden', '', @_, \%args);
}

sub hide_reply_by_id {
    shift->_hide_unhide_reply_by_id(JSON->true, @_);
}

sub unhide_reply_by_id {
    shift->_hide_unhide_reply_by_id(JSON->false, @_);
}

sub find_users_by_id {
    shift->api_v2_call(get => 'users', 'UserLookupResponse', @_);
}

sub find_users_by_username {
    shift->api_v2_call(get => 'users/by', 'UserLookupResponse', @_);
}

sub find_user_by_username {
    shift->api_v2_call(get => 'users/by/username/{username}', 'SingleUserLookupResponse', @_);
}

sub find_user_by_id {
    shift->api_v2_call(get => 'users/{id}', 'SingleUserLookupResponse', @_);
}

sub users_id_block {
    ...;
    # shift->api_v2_call(past => 'users/{id}/blocking', 'UsersBlockingMutationResponse', @_);
}

sub users_id_followers {
    shift->api_v2_call(get => 'users/{id}/followers', 'UsersFollowersLookupResponse', @_);
}

sub users_id_following {
    # Just use the followers response type. There is no difference.
    # API spec uses UsersFollowingLookupResponse
    shift->api_v2_call(get => 'users/{id}/following', 'UsersFollowersLookupResponse', @_);
}

sub users_id_follow {
    ...;
    # shift->api_v2_call(post => 'users/{id}/following', 'UsersFollowingCreateResponse', @_);
}

sub users_id_mentions {
    shift->api_v2_call(get => 'users/{id}/mentions', 'GenericTweetsTimelineResponse', @_);
}

sub users_id_tweets {
    shift->api_v2_call(get => 'users/{id}/tweets', 'GenericTweetsTimelineResponse', @_);
}

sub users_id_unblock {
    ...;
    # shift->api_v2_call(DELETE => 'users/{ source_user_id }/blocking/(target_user_id)',
    # 'UsersBlockingMutationResponse', @_);
}

sub users_id_unfollow {
    ...;
    # shift->api_v2_call(DELETE => 'users/{ source_user_id }/following/{ target_user_id }',
    # 'UsersFollowingDeleteResponse', @_);
}

1;
