require 'swiftype/version'

module Swiftype
  module Configuration
    DEFAULT_ENDPOINT = "http://swiftype.com/api/v1/"
    DEFAULT_USER_AGENT = "Swiftype-Ruby/#{Swiftype::VERSION}"

    VALID_OPTIONS_KEYS = [
      :username,
      :password,
      :user_agent,
      :endpoint
    ]

    attr_accessor *VALID_OPTIONS_KEYS

    def self.extended(base)
      base.reset
    end

    def reset
      self.username = nil
      self.password = nil
      self.endpoint = DEFAULT_ENDPOINT
      self.user_agent = DEFAULT_USER_AGENT
      self
    end

    def configure
      yield self
      self
    end

    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
      options
    end
  end
end