# Twitter-API

This is an experimental rewrite of [Net::Twitter][1] and
[Net::Twitter::Lite][2]. If it works out, I'll deprecate those modules
in favor of this one.

The final distribution name is yet to be decided, so it may change.

I have several goals for the rewrite:

* leaner
* more robust
* optional support for non-blocking IO (AnyEvent, POE, etc.)
* easier to maintain
* easier for contributors to...contribute
* immediate support for new Twitter API endpoints

To get started, clone the repository, install [Carton][3] if you don't
already have it, and run `carton install` in the working directory.

See the current examples in `xt/live`.

The core of this code is currently in `Twitter::API::request`. The idea
is to have a sequence of stages that have the proper granularity so they
can be easily augmented with roles (traits) or overridden in derived
classes to easily extend and enhance the core. The base module should be
lean, and fully functional for the most common use cases.

If you have feedback, or want to help, find me in #net-twitter on
irc.perl.org, or file an issue. Be patient on IRC. I'm away for hours at
a time, where hours is sometimes > 24.

-Marc

[1]: http://metacpan.org/pod/Net::Twitter
[2]: http://metacpan.org/pod/Net::Twitter::Lite
