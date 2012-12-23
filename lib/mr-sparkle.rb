require_relative "mr-sparkle/version"
require 'listen'

module Mr
  module Sparkle

    DEFAULT_RELOAD_PATTERN = /\.(?:builder|coffee|creole|css|erb|erubis|haml|html|js|less|liquid|mab|markdown|md|mdown|mediawiki|mkd|mw|nokogiri|radius|rb|rdoc|rhtml|ru|sass|scss|str|textile|txt|wiki|yajl|yml)$/

    DEFAULT_FULL_RELOAD_PATTERN = /^Gemfile$/

    class Daemon

      def initialize(options, unicorn_args)
        @reload_pattern = options[:pattern] || DEFAULT_RELOAD_PATTERN
        @full_reload_pattern = options[:full] || DEFAULT_FULL_RELOAD_PATTERN
        @unicorn_args = unicorn_args
      end

      def start_unicorn
        Kernel.spawn('unicorn', '-c',
          File.expand_path('mr-sparkle/unicorn.conf.rb',File.dirname(__FILE__)),
          *@unicorn_args)
      end

      def run()
        puts "Reload pattern: #{@reload_pattern}"
        @unicorn_pid = start_unicorn
        listener = Listen.to('.', :relative_paths=>true)
        listener.filter(@full_reload_pattern)
        listener.filter(@reload_pattern)
        listener.change do |modified, added, removed|
          puts "File change event detected: #{[modified, added, removed].inspect}"
          if (modified + added + removed).index {|f| f =~ @full_reload_pattern}
            # Reload everything.  Perhaps this could use the "procedure to
            # replace a running unicorn executable" described at:
            # http://unicorn.bogomips.org/SIGNALS.html
            # but one wouldn't expect this to be triggered all that much,
            # and this is just way simpler for now.
            Process.kill(:QUIT, @unicorn_pid)
            Process.wait(@unicorn_pid)
            @unicorn_pid = start_unicorn.call
          else
            # Send a HUP to unicorn to tell it to gracefully shut down its
            # workers
            Process.kill(:HUP, @unicorn_pid)
          end
        end

        shutdown = lambda do |signal|
          listener.stop
          Process.kill(:TERM, @unicorn_pid)
          Process.wait(@unicorn_pid)
          exit
        end
        Signal.trap(:INT, &shutdown)
        Signal.trap(:EXIT, &shutdown)
        
        # Ideally we would start the listener in a blocking mode and have it
        # just work.  But unfortunately listener.stop will not work from a
        # signal on the same thread the listener is running.
        # So we need to start it in the background, then keep this thread
        # alive just so it can wait to be interrupted.
        listener.start(false)
        sleep(99999) while true
      end

    end

  end
end
