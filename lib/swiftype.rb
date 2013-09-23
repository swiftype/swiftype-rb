require 'swiftype/client'

module Swiftype
  extend Swiftype::Configuration

  def self.const_missing(const_name)
    super unless const_name == :Easy
    warn "`Swiftype::Easy` has been deprecated. Use `Swiftype::Client` instead."
    Client
  end
end

