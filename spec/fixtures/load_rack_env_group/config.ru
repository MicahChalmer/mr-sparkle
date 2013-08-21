puts "HEY my rack_env is #{ENV['RACK_ENV']}"
run lambda {|env| [200, {'Content-Type' => 'text/plain; charset=utf8'}, [($gems_loaded || []).join(",")]] }
