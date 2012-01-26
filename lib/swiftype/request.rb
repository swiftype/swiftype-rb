module Swiftype
  module Request
    def get(path, params={}, options={})
      request(:get, path, params, options)
    end

    def delete(path, params={}, options={})
      request(:delete, path, params, options)
    end

    def post(path, params={}, options={})
      request(:post, path, params, options)
    end

    def put(path, params={}, options={})
      request(:put, path, params, options)
    end

    private
    def request(method, path, params, options)
      response = connection.send(method) do |request|
        case method.to_sym
        when :delete, :get
          request.url(path, params)
        when :post, :put
          request.path = path
          request.body = params unless params.empty?
        end
      end
      options[:raw] ? response : response.body
    end
  end
end