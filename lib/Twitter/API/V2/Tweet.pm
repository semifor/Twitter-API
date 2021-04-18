package Twitter::API::V2::Tweet;
# ABSTRACT: encapsulates a Twitter API v2 tweet

use Moo;
use HTML::Entities qw/decode_entities/;
use List::Util qw/first/;
use Sub::Quote;
use Time::Local qw/timegm/;
use Twitter::API::V2::User;
use Twitter::API::V2::Util qw/time_from_iso_8601/;

use namespace::clean;

extends 'Twitter::API::V2::Object';

has data => (
    is  => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
    required => 1,
);

has includes => (
    is      => 'ro',
    isa => quote_sub(q{
        die 'is not a HASH' unless ref $_[0] eq 'HASH';
    }),
);

has errors => (
    is      => 'ro',
    isa => quote_sub(q{
        die 'is not a ARRAY' unless ref $_[0] eq 'ARRAY';
    }),
);

has author => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_author',
);

sub _build_author {
    my $self = shift;

    my $author_id = $self->{data}{author_id} // return;
    my $user = first { $$_{id} eq $author_id } @{ $self->{includes}{users} };
    return Twitter::API::V2::User->new({
        data => $user,
        $self->{includes} ? ( includes => $self->{includes} ) : (),
    });
}

# default attributes
__PACKAGE__->_mk_deep_accessor(qw/data/, $_) for qw/
    attachments
    author_id
    context_annotations
    conversation_id
    created_at
    entities
    geo
    id
    in_reply_to_user_id
    lang
    non_public_metrics
    organic_metrics
    possibly_sensitive
    promoted_metrics
    public_metrics
    referenced_tweets
    reply_settings
    source
    text
    withheld
/;

__PACKAGE__->_mk_deep_accessor(qw/data public_metrics/, $_) for qw/
    quote_count
    retweet_count
    like_count
    reply_count
/;

sub created_at_time {
    time_from_iso_8601(shift->created_at);
}

sub decoded_text {
    decode_entities(shift->{data}{text});
}

sub is_retweet {
    shift->has_referenced_tweet_of_type('retweeted');
}

sub is_quote_tweet {
    shift->has_referenced_tweet_of_type('quoted');
}

sub is_reply {
    shift->has_referenced_tweet_of_type('replied_to');
}

sub has_referenced_tweet_of_type {
    my ( $self, $type ) = @_;

    my $has_type;
    for ( @{ $self->data->{referenced_tweets} // [] } ) {
        ++$has_type if $$_{type} eq $type;
    }

    return !!$has_type;
}

1;
