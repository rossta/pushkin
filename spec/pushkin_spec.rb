require 'spec_helper'

describe Pushkin do
  before(:each) do
    Pushkin.reset!
  end

  it "is version 0.0.1" do
    Pushkin::VERSION.should == '0.0.1'
  end

  it "publishes message as json to server using Faraday" do
    Pushkin.configure { |c| c.endpoint = '/faye' }
    connection = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post('/faye', "message_json") { [200, {}, 'result'] }
      end
    end
    Pushkin.stub!(:connection => connection)
    Pushkin.publish_message("message_json").should == 'result'
  end

  it "has a Faraday connection instance" do
    Pushkin.connection.should be_kind_of(Faraday::Connection)
  end

  it "has a Faye rack app instance" do
    Pushkin.server.should be_kind_of(Faye::RackAdapter)
  end

  describe "configure" do

    it "has a server endpoint" do
      Pushkin.configure { |c| c.endpoint = '/faye' }
      Pushkin.endpoint.should == '/faye'
    end

    it "has a host" do
      Pushkin.configure { |c| c.host = 'server' }
      Pushkin.host.should == 'server'
    end

    it "has a secret token" do
      Pushkin.configure { |c| c.secret_token = 'secret_token' }
      Pushkin.secret_token.should == 'secret_token'
    end

    it "has an unsettabe secret token" do
      Pushkin.configure { |c| c.signature_expiration = 600 }
      Pushkin.signature_expiration.should == 600
    end

    it "accepts hash" do
      Pushkin.configure host: 'server', endpoint: '/faye'
      Pushkin.host.should == 'server'
      Pushkin.endpoint.should == '/faye'
    end

    it "block settings take precedence" do
      Pushkin.configure host: 'server', endpoint: '/faye' do |config|
        config.host = 'server1'
        config.endpoint = '/foo'
      end
      Pushkin.host.should == 'server1'
      Pushkin.endpoint.should == '/foo'
    end
  end


  it "includes channel, server, and custom time in subscription" do
    Pushkin.configure { |c| c.host = 'localhost'; c.endpoint = '/faye' }
    subscription = Pushkin.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should eq(123)
    subscription[:channel].should == "hello"
    subscription[:server].should == 'localhost/faye'
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    Pushkin.configure { |c| c.secret_token = 'token' }
    subscription = Pushkin.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should == Digest::SHA1.hexdigest("tokenchannel123")
  end

end
