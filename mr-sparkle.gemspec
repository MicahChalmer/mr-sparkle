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
  gem.required_ruby_version = '>= 1.9.1'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency("unicorn", '>= 4.5')
  gem.add_dependency("listen", '>= 0.6')

  # Only one of these can actually be used on a given platform, but they
  # can both be installed OK--see the note about this at:
  # https://github.com/guard/guard#efficient-filesystem-handling
  gem.add_dependency('rb-inotify', '>= 0.8')
  gem.add_dependency('rb-fsevent', '>= 0.9')

  gem.add_development_dependency('minitest', '>= 4.3')
  gem.add_development_dependency('minitest-reporters', '>= 0.13')
  gem.add_development_dependency('minitest-around', '>= 0.0')
  gem.add_development_dependency('rack', '>= 1.4')
  gem.add_development_dependency('rake', '>= 10.0')
end
