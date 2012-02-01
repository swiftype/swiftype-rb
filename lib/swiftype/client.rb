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

    module Document
      def quick_update(engine_id, document_type_id, document_id, fields)
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}/update_fields.json", { :fields => fields })
      end
    end

    include Swiftype::Client::Engine
  end
end
