# NAME

Twitter::API - A Twitter REST API library for Perl

# VERSION

version 0.0100

# SYNOPSIS

    ### Common usage ###

    use Twitter::API;
    my $api = Twitter::API->new_with_traits(
        traits              => 'Enchilada',
        consumer_key        => $YOUR_CONSUMER_KEY,
        consumer_secret     => $YOUR_CONSUMER_SECRET,
        access_token        => $YOUR_ACCESS_TOKEN
        access_token_secret => $YOUR_ACCESS_TOKEN_SECRET,
    );

    my $me   = $api->verify_credentials;
    my $user = $api->show_user('twitter');

    # In list context, both the Twitter API result and a Twitter::API::Context
    # object are returned.
    my ($r, $context) = $api->home_timeline({ count => 200, trim_user => 1 });
    my $remaning = $context->rate_limit_remaining;
    my $until    = $context->rate_limit_reset;


    ### No frills ###

    my $api = Twitter::API->new(
        consumer_key    => $YOUR_CONSUMER_KEY,
        consumer_secret => $YOUR_CONSUMER_SECRET,
    );

    my $r = $api->get('account/verify_credentials', {
        -token        => $an_access_token,
        -token_secret => $an_access_token_secret,
    });

    ### Error handling ###

    use Twitter::API::Util 'is_twitter_api_error';
    use Try::Tiny;

    try {
        my $r = $api->verify_credentials;
    }
    catch {
        die $_ unless is_twitter_api_error($_);

        # The error object includes plenty of information
        say $_->http_request->as_string;
        say $_->http_response->as_string;
        say 'No use retrying right away' if $_->is_permanent_error;
        if ( $_->is_token_error ) {
            say "There's something wrong with this token."
        }
        if ( $_->twitter_error_code == 326 ) {
            say "Oops! Twitter thinks you're spam bot!";
        }
    };

# DESCRIPTION

Twitter::API provides an interface to the Twitter REST API for perl.

Features:

- full support for all Twitter REST API endpoints
- optionally, specify access tokens per API call - no need to construct a new client fo to use different user credentials \* error handling via an exception object that captures the full reqest/response context
- full support for OAuth handshake and xauth authentication

Additionl features are availble via optional traits:

- convenient methods for API endpoints with simplified argument handling via [ApiMethods](https://metacpan.org/pod/Twitter::API::Trait::ApiMethods)
- normalized booleans (Twitter likes 'true' and 'false', except when it doesn't) via [NormalizeBooleans](https://metacpan.org/pod/Twitter::API::Trait::NormalizeBooleans)
- automatic decoding of HTML entities via [DecodeHtmlEntities](https://metacpan.org/pod/Twitter::API::Trait::DecodeHtmlEntities)
- automatic retry on transient errors via [RetryOnError](https://metacpan.org/pod/Twitter::API::Trait::RetryOnError)
- "the whole enchilada" combines all the above traits via [Enchilada](https://metacpan.org/pod/Twitter::API::Trait::Enchilada)
- app-only (OAuth2) support via [AppAuth](https://metacpan.org/pod/Twitter::API::Trait::AppAuth)

Some featuers are provided by separate distributions to avoid additional
dependencies most users won't want or need:

- async support via subclass [Twitter::API::AnyEvent](https://metacpan.org/pod/Twitter::API::AnyEvent)
- inflate API call results to objects via [Twitter::API::Trait::InflateObjects](https://metacpan.org/pod/Twitter::API::Trait::InflateObjects)

# ATTRIBUTES

## consumer\_key, consumer\_secret

Required. Every application has it's own application credentials.

## access\_token, access\_token\_secret

Optional. If provided, every API call will be authenticated with these user
credentials. See [AppAuth](https://metacpan.org/pod/Twitter::API::Trait::AppAuth) for app-only (OAuth2)
support, which does not require user credentials. You can also pass options
`-token` and `-token_secret` to specify user credentials on each API call.

## api\_url

Optional. Defaults to `https://api.twitter.com`.

## upload\_url

Optional. Defaults to `https://upload.twitter.com`.

## api\_version

Optional. Defaults to `1.1`.

## agent

Optional. Used for both the User-Agent and X-Twitter-Client identifiers.
Defaults to `Twitter-API-$VERSION (Perl)`.

## timeout

Optional. Request timeout in seconds. Defaults to `10`.

# METHODS

## get($url, \[ \\%args \])

Issues an HTTP GET request to Twitter. If `$url` is just a path part, e.g.,
`account/verify_credentials`, it will be expanded to a full URL by prepending
the `api_url`, `api_version` and appending `.json`. A full URL can also be
specified, e.g. `https://api.twitter.com/1.1/account/verify_credentials.json`.

This should accommodate any new API endpoints Twitter adds without requiring an
update to this module.

## put($url, \[ \\%args \])

See `get` above, for a discussion `$url`. For file upload, pass an array
reference as described in
[https://metacpan.org/pod/distribution/HTTP-Message/lib/HTTP/Request/Common.pm#POST-url-Header-Value-...-Content-content](https://metacpan.org/pod/distribution/HTTP-Message/lib/HTTP/Request/Common.pm#POST-url-Header-Value-...-Content-content).

## get\_request\_token(\[ \\%args \])

This is the first step in the OAuth handshake. The only argument expected is
`callback`, which defaults to `oob` for PIN based verification. Web
applications will pass a callback URL.

Returns a hashref that includes `oauth_token` and `oauth_token_secret`.

See [https://dev.twitter.com/oauth/reference/post/oauth/request\_token](https://dev.twitter.com/oauth/reference/post/oauth/request_token).

## get\_authentication\_url(\\%args)

This is the second step in the OAuth handshake. The only required argument is `oauth_token`. Use the value returned by `get_request_token`. Optional arguments: `force_login` and `screen_name` to prefill Twitter's authentication form.

See [https://dev.twitter.com/oauth/reference/get/oauth/authenticate](https://dev.twitter.com/oauth/reference/get/oauth/authenticate).

## get\_authorization\_url(\\%args)

Identical to `get_authentication_url`, but uses authorization flow, rather
than authentication flow.

See [https://dev.twitter.com/oauth/reference/get/oauth/authorize](https://dev.twitter.com/oauth/reference/get/oauth/authorize).

## get\_access\_token(\\%ags)

This is the third and final step in the OAuth handshake. Pass the request `token`, request `token_secret` obtained in the `get_request_token` call, and either the PIN number if you used `oob` for the callback value in `get_request_token` or the `verifier` parameter returned in the web callback, as `verfier`.

See [https://dev.twitter.com/oauth/reference/post/oauth/access\_token](https://dev.twitter.com/oauth/reference/post/oauth/access_token).

## xauth(\\%args)

Requires per application approval from Twitter. Pass `username` and
`password`.

# AUTHOR

Marc Mims <marc@questright.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2016 by Marc Mims.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
