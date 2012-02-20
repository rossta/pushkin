require 'faye'
require 'faraday'
require 'faraday_middleware'
require "pushkin/version"
require "pushkin/configuration"
require "pushkin/connection"
require "pushkin/subscription"
require "pushkin/message"
require "pushkin/faye/authentication"
require "pushkin/engine" if defined? Rails

module Pushkin
  extend self

  def connection
    @connection ||= Connection.new(url)
  end

  delegate :host, :endpoint, to: :connection

  def reset!
    @configuration = nil
    @connection = nil
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

  delegate :url, :secret_token, :signature_expiration, to: :config

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
    Message.new(channel, data).to_hash
  end

  # Returns a subscription hash to pass to the Pushkin.sign call in JavaScript.
  # Any options passed are merged to the hash.
  def subscription(options = {})
    Subscription.new(options.merge(:url => url)).to_hash
  end

  # Returns the Faye Rack application.
  # Any options given are passed to the Faye::RackAdapter.
  def server(options = {})
    options = {:mount => endpoint, :timeout => 45, :extensions => []}.merge(options)
    ::Faye::RackAdapter.new(options)
  end

  reset!
end
