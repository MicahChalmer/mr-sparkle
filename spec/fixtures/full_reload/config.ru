require 'bundler/setup'
require 'full_reload_test_gem'
# This is loaded just once--subsequent changes to the file won't be reflected...
string_from_file = IO.read(File.expand_path("file.notwatched",File.dirname(__FILE__)))
run lambda {|env| [200, {'Content-Type' => 'text/plain'}, [string_from_file+FullReloadTestGem::THINGY]] }
