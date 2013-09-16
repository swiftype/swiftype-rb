require 'uri'
require 'swiftype/version'

module Swiftype
  module Configuration
    DEFAULT_ENDPOINT = "https://api.swiftype.com/api/v1/"
    DEFAULT_USER_AGENT = "Swiftype-Ruby/#{Swiftype::VERSION}"

    VALID_OPTIONS_KEYS = [
      :api_key,
      :user_agent,
      :platform_client_id,
      :platform_client_secret,
      :endpoint
    ]

    attr_accessor *VALID_OPTIONS_KEYS

    def self.extended(base)
      base.reset
    end

    # Reset configuration to default values.
    def reset
      self.api_key = nil
      self.endpoint = DEFAULT_ENDPOINT
      self.user_agent = DEFAULT_USER_AGENT
      self.platform_client_id = nil
      self.platform_client_secret = nil
      self
    end

    # Yields the Swiftype::Configuration module which can be used to set configuration options.
    #
    # @return self
    def configure
      yield self
      self
    end

    # Return a hash of the configured options.
    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
      options
    end

    # Set api_key and endpoint based on a URL with HTTP authentication.
    # Useful if you're using the Swiftype Heroku add-on.
    def authenticated_url=(url)
      uri = URI(url)
      self.api_key = uri.user
      uri.user = nil
      uri.password = nil
      self.endpoint = uri.to_s
    end

    # setter for endpoint that ensures it always ends in '/'
    def endpoint=(endpoint)
      if endpoint.end_with?('/')
        @endpoint = endpoint
      else
        @endpoint = "#{endpoint}/"
      end
    end
  end
end
