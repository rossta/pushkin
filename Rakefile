require 'rake'
require 'bundler/setup'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

namespace :spec do
  desc "Run javascript specs via jasmine-headless-webkit runner"
  task :javascripts do
    system "jasmine-headless-webkit -c"
  end
end

task :default => [:spec, "spec:javascripts"]
