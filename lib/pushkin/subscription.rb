module Pushkin
  class Subscription
    attr_accessor :host, :endpoint, :channel, :timestamp

    def initialize(options = {})
      @timestamp    = options[:timestamp]
      @host         = options[:host]
      @endpoint     = options[:endpoint]
      @channel      = options[:channel]
    end

    def signature
      @signature ||= Digest::SHA1.hexdigest([secret_token, channel, timestamp].join)
    end

    def signature_expired?
      return false unless expiration
      timestamp < ((Time.now.to_f - expiration)*1000).round
    end

    def expiration
      Pushkin.signature_expiration
    end

    def secret_token
      Pushkin.secret_token
    end

    def endpoint
      @endpoint ||= Pushkin.endpoint
    end

    def host
      @host ||= Pushkin.host
    end

    def server
      host + endpoint
    end

    def timestamp
      @timestamp ||= (Time.now.to_f * 1000).round
    end

    def to_hash
      {
        server: server,
        timestamp: timestamp,
        channel: channel,
        signature: signature
      }
    end

  end
end