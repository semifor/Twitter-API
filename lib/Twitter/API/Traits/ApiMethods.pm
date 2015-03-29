package Twitter::API::Traits::ApiMethods;
# Abstract: Net::Twitter like convenience methods

use Moo::Role;
use namespace::autoclean;
use strictures 2;

sub verify_credentials {
    shift->request(get => 'account/verify_credentials', @_);
}

sub mentions {
    shift->request(get => 'statuses/mentions_timeline', @_);
}

sub user_timeline {
    shift->requestn(get => 'statuses/user_timeline', @_);
}

1;


