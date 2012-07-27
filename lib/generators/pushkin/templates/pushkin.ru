# Run with: rackup pushkin.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "pushkin"

Faye::WebSocket.load_adapter('thin')

Pushkin.configure(YAML.load_file(File.expand_path("../config/pushkin.yml", __FILE__))[ENV["RAILS_ENV"] || "development"])
run Pushkin.server
