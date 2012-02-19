module Pushkin
  class Message
    def initialize(channel, data)
      @channel, @data = channel, data
    end
    
    def to_json
      {
        channel: @channel,
        data: { channel: @channel },
        ext:  { pushkin_token: Pushkin.secret_token }
      }.tap do |json|
        if @data.kind_of? String
          json[:data][:eval] = @data
        else
          json[:data][:data] = @data
        end
      end
    end
  end
end