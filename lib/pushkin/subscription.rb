module Pushkin
  class Subscription
    attr_accessor :url, :channel, :timestamp

    def initialize(options = {})
      @url       = options[:url]
      @timestamp = options[:timestamp]
      @channel   = options[:channel]
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

    def timestamp
      @timestamp ||= (Time.now.to_f * 1000).round
    end

    def to_hash
      {
        :url => url,
        :timestamp => timestamp,
        :channel => channel,
        :signature => signature
      }
    end

  end
end