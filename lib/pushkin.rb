require "pushkin/version"
require "pushkin/configuration"
require "pushkin/subscription"
require "pushkin/message"
require "pushkin/faye/authentication"

module Pushkin
  extend self

  def connection
    @connection ||= begin
      Faraday.new host do |conn|
        conn.request :json

        conn.response :logger # log the request to STDOUT
        conn.response :json,  :content_type => /\bjson$/

        conn.adapter Faraday.default_adapter
      end
    end
  end

  def reset!
    @configuration = nil
  end

  def config
    @configuration ||= Configuration.new
  end

  def configure(opts = {}, &block)
    opts.each do |attribute, setting|
      Configuration.config.send("#{attribute}=", setting)
    end
    Configuration.configure &block if block_given?
  end

  delegate :host, :endpoint, :secret_token, :signature_expiration, to: :config

  # Publish the given data to a specific channel. This ends up sending
  # a Net::HTTP POST request to the Faye server.
  def publish_to(channel, data)
    publish_message(message(channel, data))
  end

  def publish_message(message)
    response = connection.post(endpoint, message)
    response.body
  end

  def message(channel, data)
    Message.new(channel, data).to_json
  end

  # Returns a subscription hash to pass to the Pushkin.sign call in JavaScript.
  # Any options passed are merged to the hash.
  def subscription(options = {})
    Subscription.new(options).to_json
  end

  # Returns the Faye Rack application.
  # Any options given are passed to the Faye::RackAdapter.
  def server(options = {})
    options = {:mount => endpoint, :timeout => 45, :extensions => []}.merge(options)
    ::Faye::RackAdapter.new(options)
  end

  reset!
end
