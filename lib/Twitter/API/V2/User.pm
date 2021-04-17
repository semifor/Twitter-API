package Twitter::API::V2::User;
# ABSTRACT: encapsulates a Twitter API v2 tweet
use Moo;
use List::Util qw/first/;
use Sub::Quote;
use Twitter::API::V2::Tweet;
use Twitter::API::V2::Util qw/time_from_iso_8601/;
use namespace::clean;

extends 'Twitter::API::V2::Object';

has data => (
    is       => 'ro',
    isa      => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

has includes => (
    is      => 'ro',
    isa     => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
);

has pinned_tweet => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_pinned_tweet',
);

sub _build_pinned_tweet {
    my $self = shift;

    my $tweet_id = $self->{data}{pinned_tweet_id} // return;
    my $tweet = first {
        $$_{id} eq $tweet_id;
    } @{ $self->{includes}{tweets} // [] };

    return Twitter::API::V2::Tweet->new(
        data => $tweet,
        $self->{includes} ? ( includes => $self->{includes} ) : (),
    );
}

__PACKAGE__->_mk_deep_accessor(qw/data/, $_) for qw/
    created_at
    description
    entities
    id
    location
    name
    pinned_tweet_id
    profile_image_url
    protected
    public_metrics
    url
    username
    verified
    withheld
/;

__PACKAGE__->_mk_deep_accessor(qw/data public_metrics/, $_) for qw/
    followers_count
    following_count
    listed_count
    tweet_count
/;

sub created_at_time {
    time_from_iso_8601(shift->created_at // return);
}

1;
