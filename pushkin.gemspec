# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pushkin/version"

Gem::Specification.new do |s|
  s.name        = "pushkin"
  s.version     = Pushkin::VERSION
  s.authors     = ["Ross Kaffenberger"]
  s.email       = ["rosskaff@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Pub/Sub for Rails with Faye}
  s.description = %q{Pub/Sub for Rails with Faye based on PrivatePub}

  s.rubyforge_project = "pushkin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_dependency "faye"
  s.add_dependency "faraday", "0.8.1"
  s.add_dependency "faraday_middleware"
  s.add_dependency "activesupport"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "jasmine-headless-webkit"
end
