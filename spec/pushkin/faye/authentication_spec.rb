require 'spec_helper'

describe Pushkin::Faye::Authentication do
  let(:faye) { Pushkin::Faye::Authentication.new }
  let(:message) { {"channel" => "/meta/subscribe", "ext" => {}} }
  let(:callback) { lambda { |m| m } }

  it "adds an error on an incoming subscription with a bad signature" do
    message["subscription"] = "hello"
    message["ext"]["pushkin_signature"] = "bad"
    message["ext"]["pushkin_timestamp"] = "123"

    incoming = faye.incoming(message, callback)
    incoming["error"].should == "Incorrect signature."
  end

  it "has no error when the signature matches the subscription" do
    subscription = Pushkin::Subscription.new(:channel => "hello")
    message["subscription"]             = subscription.channel
    message["ext"]["pushkin_signature"] = subscription.signature
    message["ext"]["pushkin_timestamp"] = subscription.timestamp

    incoming = faye.incoming(message, callback)
    incoming["error"].should be_nil
  end

  it "has an error when signature just expired" do
    Pushkin.config.signature_expiration = 1
    subscription = Pushkin::Subscription.new(:timestamp => 123, :channel => "hello")
    message["subscription"]             = subscription.channel
    message["ext"]["pushkin_signature"] = subscription.signature
    message["ext"]["pushkin_timestamp"] = subscription.timestamp

    incoming = faye.incoming(message, callback)
    incoming["error"].should == "Signature has expired."
  end

  it "has an error when trying to publish to a custom channel with a bad token" do
    Pushkin.config.secret_token = "good"
    message["channel"] = "/custom/channel"
    message["ext"]["pushkin_token"] = "bad"

    incoming = faye.incoming(message, callback)
    incoming["error"].should == "Incorrect token."
  end

  it "raises an exception when attempting to call a custom channel without a secret_token set" do
    Pushkin.config.secret_token = nil
    message["channel"] = "/custom/channel"
    message["ext"]["pushkin_token"] = "bad"

    lambda {
      faye.incoming(message, callback)
    }.should raise_error(Pushkin::Faye::AuthenticationError)

  end

  it "has no error on other meta calls" do
    message["channel"] = "/meta/connect"

    incoming = faye.incoming(message, callback)
    incoming["error"].should be_nil

  end

  it "should not let message carry the pushkin token after server's validation" do
    Pushkin.config.secret_token = "good"

    message["channel"] = "/custom/channel"
    message["ext"]["pushkin_token"] = Pushkin.secret_token

    incoming = faye.incoming(message, callback)
    incoming['ext']["pushkin_token"].should be_nil
  end

end
