# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mr-sparkle/version'

Gem::Specification.new do |gem|
  gem.name          = "mr-sparkle"
  gem.version       = Mr::Sparkle::VERSION
  gem.authors       = ["Micah Chalmer"]
  gem.email         = ["micah@micahchalmer.net"]
  gem.description   = %q{This gem contains a script to start a Unicorn-based server for your Rack application that reloads your automatically when they are changed, but doesn't incur the penalty of reloading all the gem dependencies.  It's based on Jonathan D. Stott's blog post "Magical Reloading Sparkles"--hence the name.}
  gem.summary       = %q{Runs Unicorn, automatically reloading the application, but not bundled gems.}
  gem.homepage      = "http://github.com/MicahChalmer/mr-sparkle"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
