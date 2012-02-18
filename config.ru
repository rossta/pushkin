# Run with: rackup pushkin.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "pushkin"

Pushkin.configure do |config|
  config.host         = "http://localhost:9292"
  config.endpoint     = "/faye"
  config.secret_token = "secret"
end

run Pushkin.server
