Twitter-API
===========
![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)
[![Build Status](https://travis-ci.org/semifor/Twitter-API.svg?branch=master)](https://travis-ci.org/semifor/Twitter-API)
[![CPAN](https://img.shields.io/cpan/v/Twitter-API.svg)](https://metacpan.org/pod/Twitter::API)


This is a rewrite of [Net::Twitter][1] and [Net::Twitter::Lite][2]. If it works out, I'll deprecate those modules in favor of this one.

I have several goals for the rewrite:
* leaner
* more robust
* optional support for non-blocking IO (AnyEvent, POE, etc.)
* easier to maintain
* easier to grok, so easier for contributers to…contribute
* support new API endpoints without necessitating a new distribution release

Install
-------

To get started, clone the repository, install [Carton][3] if you don't already have it, and run `carton install` in the working directory.

See the [current examples](examples).

The core of this code is currently in `Twitter::API::request`. The idea is to have a sequence of stages that have the proper granularity so they can be easily augmented with roles (traits) or overridden in derived classes to easily extend and enhance the core. The base module should be lean, and fully functional for the most common use cases.

Feedback
--------

If you have feedback, or want to help, find me in [#net-twitter][4] on irc.perl.org, or file an issue. Be patient on IRC. I'm away for hours, sometimes days, at a time.

[1]: http://metacpan.org/pod/Net::Twitter
[2]: http://metacpan.org/pod/Net::Twitter::Lite
[3]: http://metacpan.org/pod/Carton
[4]: irc:://irc.perl.org#net-twitter
