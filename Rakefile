require 'rake'
require 'bundler/setup'
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

require 'jasmine-headless-webkit'
Jasmine::Headless::Task.new

task :default => [:spec, "jasmine:headless"]
