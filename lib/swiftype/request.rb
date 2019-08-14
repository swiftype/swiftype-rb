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
      Timeout.timeout(overall_timeout) do
        uri = URI.parse("#{Swiftype.endpoint}#{path}")

        request = build_request(method, uri, params)

        if proxy
          proxy_parts = URI.parse(proxy)
          http = Net::HTTP.new(uri.host, uri.port, proxy_parts.host, proxy_parts.port, proxy_parts.user, proxy_parts.password)
        else
          http = Net::HTTP.new(uri.host, uri.port)
        end

        http.open_timeout = open_timeout
        http.read_timeout = overall_timeout

        if uri.scheme == 'https'
          http.use_ssl = true
          # st_ssl_verify_none provides a means to disable SSL verification for debugging purposes. An example
          # is Charles, which uses a self-signed certificate in order to inspect https traffic. This will
          # not be part of this client's public API, this is more of a development enablement option
          http.verify_mode = ENV['st_ssl_verify_none'] == 'true' ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
          http.ca_file = File.join(File.dirname(__FILE__), '..', 'data', 'ca-bundle.crt')
          http.ssl_timeout = open_timeout
        end

        response = http.request(request)
        handle_errors(response)
        JSON.parse(response.body) if response.body && response.body.strip != ''
      end
    end

    private
    def handle_errors(response)
      case response
      when Net::HTTPSuccess
        response
      else
        EXCEPTION_MAP.each do |response_class, exception_class|
          if response.is_a?(response_class)
            raise exception_class, error_message_from_response(response)
          end
        end

        raise Swiftype::UnexpectedHTTPException, "#{response.code} #{response.body}"
      end
    end

    EXCEPTION_MAP = {
      Net::HTTPUnauthorized => Swiftype::InvalidCredentials,
      Net::HTTPNotFound => Swiftype::NonExistentRecord,
      Net::HTTPConflict => Swiftype::RecordAlreadyExists,
      Net::HTTPBadRequest => Swiftype::BadRequest,
      Net::HTTPForbidden => Swiftype::Forbidden,
      Net::HTTPInternalServerError => Swiftype::InternalServerError,
      Net::HTTPBadGateway => Swiftype::BadGateway,
      Net::HTTPServiceUnavailable => Swiftype::ServiceUnavailable,
      Net::HTTPGatewayTimeOut => Swiftype::GatewayTimeout
    }.freeze

    def error_message_from_response(response)
      body = response.body
      json = JSON.parse(body) if body && body.strip != ''
      return json['error'] if json && json.key?('error')
      body
    rescue JSON::ParserError
      body
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
