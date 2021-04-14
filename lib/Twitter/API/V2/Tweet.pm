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
sub id   { shift->{data}{id} }
sub text { shift->{data}{text} }

# when included in tweet.fields parameter
sub attachments         { shift->{data}{attachments} }
sub author_id           { shift->{data}{author_id} }
sub context_annotations { shift->{data}{context_annotations} }
sub conversation_id     { shift->{data}{conversation_id} }
sub created_at          { shift->{data}{created_at} }
sub entities            { shift->{data}{entities} }
sub geo                 { shift->{data}{geo} }
sub in_reply_to_user_id { shift->{data}{in_reply_to_user_id} }
sub lang                { shift->{data}{lang} }
sub non_public_metrics  { shift->{data}{non_public_metrics} }
sub public_metrics      { shift->{data}{public_metrics} }
sub organic_metrics     { shift->{data}{organic_metrics} }
sub promoted_metrics    { shift->{data}{promoted_metrics} }
sub possibly_sensitive  { shift->{data}{possibly_sensitive} }
sub referenced_tweets   { shift->{data}{referenced_tweets} }
sub reply_settings      { shift->{data}{reply_settings} }
sub source              { shift->{data}{source} }
sub withheld            { shift->{data}{withheld} }

sub created_at_time {
    time_from_iso_8601(shift->created_at // return);
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
