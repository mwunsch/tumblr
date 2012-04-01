# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tumblr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Wunsch"]
  gem.email         = ["mark@markwunsch.com"]
  gem.description   = %q{Ruby library and command line utility to interact with the Tumblr API.}
  gem.summary       = %q{Ruby library and command line utility to interact with Tumblr.}
  gem.homepage      = %q{http://github.com/mwunsch/tumblr}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tumblr-rb"
  gem.require_paths = ["lib"]
  gem.version       = Tumblr::VERSION

  # gem.add_runtime_dependency "weary", "~> 1.0.0.rc1"
end
