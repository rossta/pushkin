require 'spec_helper'

describe Pushkin::Connection do
  let(:url) { 'http://localhost:9292/faye' }
  let(:connection) { Pushkin::Connection.new(url) }

  it "has a Faraday connection instance" do
    connection.faraday.should be_kind_of(Faraday::Connection)
  end

  it "publishes message as json to server using Faraday" do
    faraday = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post('/faye', "message_json") { [200, {}, 'result'] }
      end
    end
    connection.stub!(:faraday => faraday)
    connection.deliver("message_json").body.should == 'result'
  end

end
