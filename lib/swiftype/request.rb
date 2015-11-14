require 'net/https'
if RUBY_VERSION < '1.9'
  require 'swiftype/ext/backport-uri'
else
  require 'uri'
end
require 'json'
require 'swiftype/exceptions'
require 'openssl'

module Swiftype
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

    # Poll a block with backoff until a timeout is reached.
    #
    # @param [Hash] options optional arguments
    # @option options [Numeric] :timeout (10) Number of seconds to wait before timing out
    #
    # @yieldreturn a truthy value to return from poll
    # @yieldreturn [false] to continue polling.
    #
    # @return the truthy value returned from the block.
    #
    # @raise [Timeout::Error] when the timeout expires
    def poll(options={})
      timeout = options[:timeout] || 10
      delay = 0.05
      Timeout.timeout(timeout) do
        while true
          res = yield
          return res if res
          sleep delay *= 2
        end
      end
    end

    # Construct and send a request to the API.
    #
    # @raise [Timeout::Error] when the timeout expires
    def request(method, path, params={})
      uri = URI.parse("#{Swiftype.endpoint}#{path}")

      request = build_request(method, uri, params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = open_timeout

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = File.join(File.dirname(__FILE__), '..', 'data', 'ca-bundle.crt')
      end

      response = nil
      Timeout.timeout(overall_timeout) do
        response = http.request(request)
      end

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
      when Net::HTTPBadRequest
        raise Swiftype::BadRequest
      when Net::HTTPForbidden
        raise Swiftype::Forbidden
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
        uri.query = URI.encode_www_form(params) if params && !params.empty?
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
