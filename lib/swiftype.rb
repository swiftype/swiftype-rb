require 'ostruct'
require 'faraday'
require 'faraday_middleware'
require 'swiftype/exceptions'

module Swiftype
  autoload :Configuration, 'swiftype/configuration'
  autoload :Connection, 'swiftype/connection'
  autoload :Client, 'swiftype/client'
  autoload :BaseModel, 'swiftype/base_model'
  autoload :Request, 'swiftype/request'
  autoload :Search, 'swiftype/search'
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

    def deprecation_notice!
      ActiveSupport::Deprecation.warn(
        %{You're using a very old client to access Swiftype. The gem named 'swiftype-rb' is deprecated,
has not received updates since August 2012, and will receive no further updates.

Please switch to using the 'swiftype' gem instead, at your convenience; it is far
better maintaned, supported, and documented.}, caller)
    end
  end
end

::Swiftype.deprecation_notice!
