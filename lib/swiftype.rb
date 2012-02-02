require 'ostruct'
require 'faraday'
require 'faraday_middleware'

module Swiftype
  autoload :Configuration, 'swiftype/configuration'
  autoload :Connection, 'swiftype/connection'
  autoload :Client, 'swiftype/client'
  autoload :BaseModel, 'swiftype/base_model'
  autoload :Request, 'swiftype/request'
  autoload :Engine, 'swiftype/engine'
  autoload :DocumentType, 'swiftype/document_type'
  autoload :Document, 'swiftype/document'
  autoload :Easy, 'swiftype/easy'

  extend Configuration

  class << self
    def new(options={})
      Swiftype::Client.new(options)
    end

    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private=false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end
  end
end

