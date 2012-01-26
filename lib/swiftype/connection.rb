module Swiftype
  module Connection
    include Swiftype::Request

    def connection
      @connection ||= begin
        conn = Faraday.new(Swiftype.endpoint) do |b|
          b.response :raise_error
          b.use Faraday::Request::UrlEncoded
          b.use FaradayMiddleware::ParseJson
          b.use FaradayMiddleware::Mashify
          b.adapter Faraday.default_adapter
        end

        conn.basic_auth Swiftype.username, Swiftype.password
        conn.headers['User-Agent'] = Swiftype.user_agent

        conn
      end
    end
  end
end
