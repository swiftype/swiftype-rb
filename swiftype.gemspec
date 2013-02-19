# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "swiftype/version"

Gem::Specification.new do |s|
  s.name        = "swiftype"
  s.version     = Swiftype::VERSION
  s.authors     = ["Quin Hoxie", "Matt Riley"]
  s.email       = ["team@swiftype.com"]
  s.homepage    = "http://swiftype.com"
  s.summary     = %q{Swiftype API Gem}
  s.description = %q{Official gem for accessing the Swiftype Search API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "json", ['~> 1.7.7']
  s.add_runtime_dependency "faraday", ['~> 0.8.1']
  s.add_runtime_dependency "faraday_middleware", ['~> 0.8.7']
  s.add_runtime_dependency "hashie", ['~> 1.2.0']
  s.add_runtime_dependency 'activesupport', ['>= 2.3.9', '< 4']
end
