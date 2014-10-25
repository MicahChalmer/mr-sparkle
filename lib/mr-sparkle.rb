require_relative "mr-sparkle/version"
require 'listen'

module Mr
  module Sparkle

    DEFAULT_RELOAD_PATTERN = /\.(?:builder|coffee|creole|css|erb|erubis|haml|html|js|less|liquid|mab|markdown|md|mdown|mediawiki|mkd|mw|nokogiri|radius|rb|rdoc|rhtml|ru|sass|scss|str|textile|txt|wiki|yajl|yml)$/

    DEFAULT_FULL_RELOAD_PATTERN = /^Gemfile(?:\.lock)?$/

    class Daemon

      def start_unicorn
        @unicorn_pid = Kernel.spawn('unicorn', '-c',
          File.expand_path('mr-sparkle/unicorn.conf.rb',File.dirname(__FILE__)),
          *@unicorn_args)
      end

      def run(options, unicorn_args)
        reload_pattern = options[:pattern] || DEFAULT_RELOAD_PATTERN
        full_reload_pattern = options[:full] || DEFAULT_FULL_RELOAD_PATTERN
        force_polling = options[:force_polling] || false
        @unicorn_args = unicorn_args
        reload_pattern = Regexp.union(reload_pattern, full_reload_pattern)
        listener = Listen.to(Dir.pwd, only: reload_pattern, force_polling: force_polling) do |modified, added, removed|
          $stderr.puts "File change event detected: #{{modified: modified, added: added, removed: removed}.inspect}"
          if (modified + added + removed).index {|f| File.basename(f) =~ full_reload_pattern}
            # Reload everything.  Perhaps this could use the "procedure to
            # replace a running unicorn executable" described at:
            # http://unicorn.bogomips.org/SIGNALS.html
            # but one wouldn't expect this to be triggered all that much,
            # and this is just way simpler for now.
            Process.kill(:QUIT, @unicorn_pid)
            Process.wait(@unicorn_pid)
            start_unicorn
          else
            # Send a HUP to unicorn to tell it to gracefully shut down its
            # workers
            Process.kill(:HUP, @unicorn_pid)
          end
        end

        shutdown = lambda do |signal|
          Thread.new { Listen.stop }
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
        listener.start
        # Theoretically, we could have problems if a file changed RIGHT AT
        # THIS POINT, between the time we started the listener and the time
        # we started the unicorn process.  But this is just for development,
        # so we're just not going to worry about that.
        start_unicorn

        # And now we just want to keep the thread alive--we're just waiting around to get interrupted at this point.
        sleep(99999) while true
      end

    end

  end
end
