package Twitter::API::Error;

use Moo;
use strictures 2;
use namespace::autoclean;

use overload '""' => 'message';

with 'Throwable';

has message => (
    is       => 'rw',
    required => 1,
);

has context => (
    is       => 'rw',
    required => 1,
);

has twitter_error => (
    is       => 'rw',
    required => 1,
);

1;
