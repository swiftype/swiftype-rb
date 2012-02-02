module Swiftype
  class Client
    include Swiftype::Connection

    def initialize(options={})
    end

    module Engine
      def engine(id)
        Swiftype::Engine.find(id)
      end

      def create_engine(attributes)
        Swiftype::Engine.new(attributes).create!
      end

      def update_engine(id, attributes)
        engine = Swiftype::Engine.find(id)
        engine.merge!(attributes)
        engine.update!(attributes)
      end

      def destroy_engine(id)
        Swiftype::Engine.find(id).destroy!
      end
    end

    include Swiftype::Client::Engine
  end
end
