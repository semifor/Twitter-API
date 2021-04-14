package Twitter::API::V2::User;
# ABSTRACT: encapsulates a Twitter API v2 tweet
use Moo;
use List::Util qw/first/;
use Sub::Quote;
use Twitter::API::V2::Tweet;
use Twitter::API::V2::Util qw/time_from_iso_8601/;
use namespace::clean;

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

# default attributes
sub id                { shift->{data}{id} }
sub name              { shift->{data}{name} }
sub username          { shift->{data}{username} }

sub created_at        { shift->{data}{created_at} }
sub description       { shift->{data}{description} }
sub location          { shift->{data}{location} }
sub pinned_tweet_id   { shift->{data}{pinned_tweet_id} }
sub profile_image_url { shift->{data}{profile_image_url} }
sub protected         { shift->{data}{protected} }
sub public_metrics    { shift->{data}{public_metrics} }
sub url               { shift->{data}{url} }
sub verified          { shift->{data}{verified} }
sub withheld          { shift->{data}{withheld} }

sub entities          { shift->{data}{entities} }

# from public metrics
sub followers_count { shift->{data}{public_metrics}{followers_count} }
sub following_count { shift->{data}{public_metrics}{following_count} }
sub listed_count    { shift->{data}{public_metrics}{listed_count} }
sub tweet_count     { shift->{data}{public_metrics}{tweet_count} }

1;
