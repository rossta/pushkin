# Run with: rackup pushkin.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "pushkin"

Pushkin.configure do |config|
  config.url          = "http://localhost:9292/faye"
  config.secret_token = "secret"
end

run Pushkin.server
