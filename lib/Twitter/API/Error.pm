package Twitter::API::Error;

use Moo;
use strictures 2;
use namespace::autoclean;

use overload '""' => 'stringify';

with 'Throwable';

has [ qw/message context response twitter_error/ ] => (
    is       => 'rw',
    required => 1,
);

sub stringify { shift->message }

1;
