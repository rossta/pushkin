require 'securerandom'
require 'active_support/configurable'

module Pushkin
  class Configuration
    include ActiveSupport::Configurable

    config_accessor :url, :secret_token, :signature_expiration

    def self.generate_token
      defined?(SecureRandom) ? SecureRandom.hex(32) : ActiveSupport::SecureRandom.hex(32)
    end

    # Pushkin.configure do |config|
    #   config.url = 'http://localhost:9292/faye'
    #   config.secret_token = generate_token
    #   config.signature_expiration = 3600    # 1 hour
    # end

  end
end
