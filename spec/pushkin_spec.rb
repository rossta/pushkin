require 'spec_helper'

describe Pushkin do
  before(:each) do
    Pushkin.reset!
  end

  it "publishes message as json to server using Faraday" do
    connection = mock('Connection', :endpoint => '/faye')
    connection.should_receive(:post).with('/faye', 'message_json').and_return(mock(:body => 'result'))
    Pushkin.stub!(:connection => connection)
    Pushkin.publish_message("message_json").should == 'result'
  end

  it "has a Faye rack app instance" do
    Pushkin.configure { |c| c.url = 'http://localhost:9292/faye'}
    Pushkin.server.should be_kind_of(Faye::RackAdapter)
  end

  it "includes channel, server, and custom time in subscription" do
    Pushkin.configure { |c| c.url = 'localhost/faye' }
    subscription = Pushkin.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should eq(123)
    subscription[:channel].should == "hello"
    subscription[:url].should == 'localhost/faye'
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    Pushkin.configure { |c| c.secret_token = 'token' }
    subscription = Pushkin.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should == Digest::SHA1.hexdigest("tokenchannel123")
  end

  it "formats a message hash given a channel and a string for eval" do
    Pushkin.configure { |c| c.secret_token = "token" }
    Pushkin.message("chan", "foo").should eq(
      :ext => {:pushkin_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :eval => "foo"
      }
    )
  end

  it "formats a message hash given a channel and a hash" do
    Pushkin.configure { |c| c.secret_token = "token" }
    Pushkin.message("chan", :foo => "bar").should eq(
      :ext => {:pushkin_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :data => {:foo => "bar"}
      }
    )
  end

  it "publish_to passes message to publish_message call" do
    Pushkin.should_receive(:message).with("chan", "foo").and_return("message")
    Pushkin.should_receive(:publish_message).with("message").and_return(:result)
    Pushkin.publish_to("chan", "foo").should eq(:result)
  end

  describe "configure" do

    it "has a server url" do
      Pushkin.configure { |c| c.url = 'http://localhost:9292/faye' }
      Pushkin.url.should == 'http://localhost:9292/faye'
    end

    it "has a server endpoin" do
      Pushkin.configure { |c| c.url = 'http://localhost:9292/faye' }
      Pushkin.endpoint.should == '/faye'
    end

    it "has a host" do
      Pushkin.configure { |c| c.url = 'http://localhost:9292/faye' }
      Pushkin.host.should == 'http://localhost:9292'
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
      Pushkin.configure :url => 'http://localhost:9292/faye'
      Pushkin.url.should == 'http://localhost:9292/faye'
      Pushkin.host.should == 'http://localhost:9292'
      Pushkin.endpoint.should == '/faye'
    end

    it "block settings take precedence" do
      Pushkin.configure :url => 'http://localhost:9292/faye' do |config|
        config.url = 'http://localhost:2929/foobar'
        config.endpoint = '/foo'
      end
      Pushkin.url.should == 'http://localhost:2929/foobar'
      Pushkin.host.should == 'http://localhost:2929'
      Pushkin.endpoint.should == '/foobar'
    end
  end

end
