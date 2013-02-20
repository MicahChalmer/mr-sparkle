require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/around'
require 'net/http'
require 'tmpdir'
require 'timeout'
require 'bundler'

MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new

# Max # of seconds to wait before declaring the test failed
WAIT_TIMEOUT=10

class ServerAppTest < MiniTest::Spec

  attr_accessor :app_template_path # Path to the test fixture application to run

  # Use this to get paths for app_template_path
  def app_template_fixture(name)
    File.expand_path("fixtures/#{name}",File.dirname(__FILE__))
  end

  attr_reader :running_app_dir
  attr_reader :app_pid
  attr_reader :app_stdout
  attr_reader :app_stderr

  attr_writer :app_command
  def app_command
    @app_command ||= File.expand_path('../bin/mr-sparkle',File.dirname(__FILE__))
  end

  attr_writer :app_args
  def app_args
    # We want unicorn not to listen on non-local ports.  We also use a different port
    # than the usual test server...
    @app_args || []
  end

  def start_app
    stop_app
    @app_socket_path = File.expand_path("main_unicorn_socket", running_app_dir)
    Dir.mkdir(File.expand_path('log', running_app_dir))
    @app_stdout, app_stdout_w = IO.pipe
    @app_stderr, app_stderr_w = IO.pipe
    Bundler.with_clean_env do
      # Need to generate the right Gemfile.lock so that we don't generate it
      # from the app itself, creating spurious reload events
      unless File.exists?(File.expand_path('Gemfile.lock', running_app_dir))
        Kernel.system('bundle install --local', chdir: running_app_dir, 
          in: '/dev/null', out: '/dev/null', err: '/dev/null')
      end
      @app_pid = Kernel.spawn(
        app_command, *app_args, '--', '-l', @app_socket_path,
        {pgroup: true, chdir: running_app_dir,
          in: '/dev/null', out: app_stdout_w, err: app_stderr_w})
      app_stdout_w.close
      app_stderr_w.close
    end
    
    @old_handler = Signal.trap(:EXIT) do
      stop_app
      @old_handler.call if @old_handler
    end
    watch_until {|line| File.exists?(@app_socket_path)}
  end

  def watch_until(stream=@app_stderr, &block)
    Timeout.timeout(WAIT_TIMEOUT) do
      stream.each_line do |line|
        return true if block.call(line)
      end
    end
  end

  def app_request(path)
    # Hat tip to:
    # http://code.google.com/p/semicomplete/source/browse/codesamples/ruby-supervisorctl.rb?spec=svn3046&r=3046
    # for how this works
    sock = Net::BufferedIO.new(UNIXSocket.new(@app_socket_path))
    req = Net::HTTP::Get.new(path)
    req.exec(sock, "1.1", path)
    begin
      response = Net::HTTPResponse.read_new(sock)
    end while response.kind_of?(Net::HTTPContinue)
    response.reading_body(sock, req.response_body_permitted?) { }

    response
  end

  def stop_app
    if @app_pid
      Process.kill(:TERM, -@app_pid) # Negate the pid to kill the whole process group
      Process.wait(@app_pid)
      @app_pid = nil
    end
    
    Signal.trap(:EXIT, @old_handler) if @old_handler
    @old_handler = nil
  end

  def change_file(file_name, pattern, replacement)
    full_file_name = File.expand_path(file_name,@running_app_dir)
    contents = IO.read(full_file_name)
    IO.write(full_file_name, contents.gsub(pattern,replacement))
  end

  def watch_until_change_detected(&block)
    watch_until do |line| 
      /^File change event detected/.match(line) && (block.nil? || block.call(line))
    end
    # It won't really serve the new version until it starts its new worker process
    watch_until {|line| /worker=\d+ ready/.match(line)}
  end

  def around
    raise "Must set @app_template_path" if @app_template_path.nil?
    Dir.mktmpdir do |dir|
      FileUtils.cp_r("#{app_template_path}/.", dir)
      @running_app_dir = dir
      begin
        yield
      rescue Exception=>e
        puts e.inspect
        stop_app
        begin
          Timeout.timeout(1) do
            puts "App stdout: #{@app_stdout.read}"
            puts "App stderr: #{@app_stderr.read}"
          end
        rescue Exception=>f
          puts "Exception while printing app stderr/stdout: #{f.inspect}"
        end
        raise
      ensure
        stop_app
      end
    end
  end
  
end

MiniTest::Spec.register_spec_type(/^App Runner:/, ServerAppTest)
