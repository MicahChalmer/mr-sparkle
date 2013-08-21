# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "my_development_gem"
  gem.version       = '0.0.1'
  gem.authors       = ["Micah Chalmer"]
  gem.email         = ["micah@micahchalmer.net"]
  gem.description   = %q{This is only here as part of a test fixture}
  gem.summary       = %q{This is only here as part of a test fixture}
  gem.homepage      = ""

  gem.files         = ['lib/my_development_gem.rb']
  gem.executables   = []
  gem.test_files    = []
  gem.require_paths = ["lib"]
end
