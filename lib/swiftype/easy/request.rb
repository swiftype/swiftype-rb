require 'net/https'
if RUBY_VERSION < "1.9"
  require 'swiftype/ext/backport-uri'
else
  require 'uri'
end
require 'json'
require 'swiftype/exceptions'
require 'openssl'

module Swiftype
  class Easy
    module Request
      def get(path, params={})
        request(:get, path, params)
      end

      def post(path, params={})
        request(:post, path, params)
      end

      def put(path, params={})
        request(:put, path, params)
      end

      def delete(path, params={})
        request(:delete, path, params)
      end

      def request(method, path, params={})
        uri = URI.parse("#{Swiftype.endpoint}#{path}")

        request = build_request(method, uri, params)
        http = Net::HTTP.new(uri.host, uri.port)
        # TODO!
        #http.use_ssl = true

        response = http.request(request)

        handle_errors(response)

        JSON.parse(response.body) if response.body && response.body.strip != ''
      end

      private

      def handle_errors(response)
        case response
        when Net::HTTPSuccess
          response
        when Net::HTTPUnauthorized
          raise Swiftype::InvalidCredentials
        when Net::HTTPNotFound
          raise Swiftype::NonExistentRecord
        when Net::HTTPConflict
          raise Swiftype::RecordAlreadyExists
        else
          raise Swiftype::UnexpectedHTTPException, "#{response.code} #{response.body}"
        end
      end

      def build_request(method, uri, params)
        klass = case method
                when :get
                  Net::HTTP::Get
                when :post
                  Net::HTTP::Post
                when :put
                  Net::HTTP::Put
                when :delete
                  Net::HTTP::Delete
                end

        case method
        when :get, :delete
          uri.query = URI.encode_www_form(params)
          req = klass.new(uri.request_uri)
        when :post, :put
          req = klass.new(uri.request_uri)
          req.body = JSON.generate(params) unless params.length == 0
        end

        req['User-Agent'] = Swiftype.user_agent
        req['Content-Type'] = 'application/json'

        if platform_access_token
          req['Authorization'] = "Bearer #{platform_access_token}"
        elsif api_key
          req.basic_auth api_key, ''
        end

        req
      end
    end
  end
end
