# Run with: rackup pushkin.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "pushkin"

Pushkin.configure(File.expand_path("../config/pushkin.yml", __FILE__)[ENV["RAILS_ENV"] || "development"])
run Pushkin.server
