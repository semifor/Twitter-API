package Twitter::API::Error;

use Moo;
use strictures 2;
use namespace::clean;

use overload '""' => 'stringify';

with 'Throwable';

has [ qw/message context twitter_error/ ] => (
    is       => 'ro',
    required => 1,
);

sub http_request  { shift->context->{http_request}  }
sub http_response { shift->context->{http_response} }

sub stringify { shift->message }

1;
