module Swiftype
  module Connection
    include Swiftype::Request

    def connection
      raise(InvalidCredentials, "You must supply credentials to Swiftype.configure") unless (Swiftype.username && Swiftype.password ) || Swiftype.api_key

      @connection ||= begin
        conn = Faraday.new(Swiftype.endpoint) do |b|
          b.response :raise_error
          b.use Faraday::Request::UrlEncoded
          b.use FaradayMiddleware::ParseJson
          b.use FaradayMiddleware::Mashify
          b.use ApiResponseMiddleware
          b.adapter Faraday.default_adapter
        end

        conn.basic_auth Swiftype.username, Swiftype.password if Swiftype.username && Swiftype.password
        conn.headers['User-Agent'] = Swiftype.user_agent

        conn
      end
    end

    class ApiResponseMiddleware < Faraday::Response::Middleware
      def on_complete(env)
        case env[:status]
        when 200, 201, 204
          nil
        when 401
          raise InvalidCredentials
        when 404
          raise NonExistentRecord
        when 409
          raise RecordAlreadyExists
        else
          raise UnexpectedHTTPException, env[:body]
        end
      end

      def initialize(app)
        super
        @parser = nil
      end
    end
  end
end
