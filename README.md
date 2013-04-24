# Mr. Sparkle - The Magical Reloading Rack Server

[![Build Status](https://travis-ci.org/MicahChalmer/mr-sparkle.png)](https://travis-ci.org/MicahChalmer/mr-sparkle)

This gem contains a script to start a [Unicorn](http://unicorn.bogomips.org/)-based server for your [Rack](http://rack.github.com/) application that reloads your application code automatically when its files are changed, but doesn't incur the penalty of reloading all the gem dependencies.  It's based on Jonathan D. Stott's blog post ["Magical Reloading Sparkles"](http://namelessjon.posterous.com/magical-reloading-sparkles)--hence the name.  (The name is also a Simpsons reference.  [CAN YOU SEE THAT I AM SERIOUS?](http://www.youtube.com/watch?v=dnaLRbbc-54))

The main purpose of this gem is to take Jonathan's idea and package it into something can "just work" without having to be customized inside each project's code.  Besides the gem packaging, this code differs from the original watcher script in the following ways:

1. It uses [listen](https://github.com/guard/listen) instead of [directory_watcher](https://github.com/TwP/directory_watcher/), which provides native event-driven file change detection, instead of polling.
1. It assumes you're using [Bundler](http://gembundler.com/) for dependencies, which means that instead of needing a hardcoded list of gems in the `before_fork` hook, like the blog post had, this plugin just does `Bundler.require(:default)` to get all the modules mentioned in the Gemfile loaded before forking.
1. If you change your Gemfile, the preloads are no longer valid, so this script treats that change as a special case: when the Gemfile changes, we kill the whole server and restart it, thus reloading absolutely everything.

The script comes with a default set of file extensions it will watch for changes.  I've tried to be liberal about it--no harm reloading a few extra times when developing.  You can run `mr-sparkle --help` to see the default set as a regexp, and you can change that regexp with the `--pattern` option.

## Installation

    $ gem install mr-sparkle

## Usage

If you've got a Rack app that uses Bundler for its dependencies, then ordinarily all you have to do is execute

    $ mr-sparkle
    
in your project's root directory.  You'll get a server listening on port 8080 (bound to all addresses, so external machines WILL be able to connect to it by default) and your code will be reloaded if any relevant files change.

You can use command-line options to change the behavior a bit as follows:

    $ mr-sparkle [--pattern regex] [--full-reload-pattern regex] [-- [unicorn options]]

Use `--pattern` to replace the default regex that files must match to trigger a reload.  I've tried to make the default fairly liberal--it includes all extensions registered with [tilt](https://github.com/rtomayko/tilt/), for instance--so for most apps it will probably work fine.

Use `--full-reload-pattern` to trigger a full reload for a different set of files.  By default it only does this for `Gemfile.`

Any arguments after the `--` will be passed on to unicorn.  This is how you would change the default port, make it not bind to external ip addresses, use a rackup file with a name other than `config.ru`, etc.  See [the unicorn documentation](http://unicorn.bogomips.org/unicorn_1.html) for exactly what you can pass here.  Do not pass the `-c` option to unicorn--`mr-sparkle` comes with its own unicorn config file that it will use automatically.

## Requirements

This script requires Ruby 1.9.1 or greater (because it depends on `Kernel.spawn`.)  Since it's a wrapper around Unicorn, it will only work on "unix or unix-like" systems where unicorn is supported.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
