# -*- encoding: utf-8 -*-
require File.expand_path('../lib/em-irc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jerry Cheung"]
  gem.email         = ["jch@whatcodecraves.com"]
  gem.description   = %q{em-irc is an IRC client that uses EventMachine to handle connections to servers}
  gem.summary       = %q{em-irc is an IRC client that uses EventMachine to handle connections to servers}
  gem.homepage      = "http://github.com/jch/em-irc"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "em-irc"
  gem.require_paths = ["lib"]
  gem.version       = EventMachine::IRC::VERSION

  gem.add_runtime_dependency 'eventmachine'
  gem.add_runtime_dependency 'activesupport'
end
