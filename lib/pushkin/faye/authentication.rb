module Pushkin
  module Faye
    class AuthenticationError < StandardError; end

    class Authentication
      def incoming(message, callback)
        if message["channel"] == '/meta/subscribe'
          authenticate_subscribe(message)
        elsif message["channel"] !~ %r{^/meta/}
          authenticate_publish(message)
        end
        callback.call(message)
      end

      def authenticate_subscribe(message)
        signature = message["ext"]["pushkin_signature"]
        timestamp = message["ext"]["pushkin_timestamp"]

        subscription = Pushkin::Subscription.new \
          :channel => message["subscription"],
          :timestamp => timestamp

        if signature != subscription.signature
          message["error"] = "Incorrect signature."
        elsif subscription.signature_expired?
          message["error"] = "Signature has expired."
        end
      end

      def authenticate_publish(message)
        if Pushkin.secret_token.nil?
          raise AuthenticationError.new("No secret_token config set")
        elsif message["ext"]["pushkin_token"] != Pushkin.secret_token
          message["error"] = "Incorrect token."
        else
          message["ext"]["pushkin_token"] = nil
        end
      end
    end
  end
end