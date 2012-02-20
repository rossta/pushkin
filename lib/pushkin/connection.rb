module Pushkin
  class Connection

    def initialize(url)
      @url = url
    end

    def faraday
      @faraday ||= begin
        Faraday.new host do |conn|
          conn.request :json

          conn.response :logger # log the request to STDOUT
          conn.response :json,  :content_type => /\bjson$/

          conn.adapter Faraday.default_adapter
        end
      end
    end

    def host
      uri.to_s.gsub(/#{Regexp.escape(endpoint)}$/, "")
    end

    def endpoint
      uri.path
    end

    def uri
      URI.parse(@url)
    end

    def post(*args)
      faraday.post(endpoint, *args)
    end

  end
end