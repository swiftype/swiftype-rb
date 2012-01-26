require 'active_support/inflector'

module Swiftype
  class BaseModel < Hashie::Dash
    include Swiftype::Connection
    include Swiftype::Request

    class << self
      def model_name
        name.split('::').last.underscore
      end

      def collection_name
        model_name.pluralize
      end

      def find(id)
        new Swiftype::Client.new.get("/api/v1/#{collection_name}/#{id}.json")
      end
    end

    def initialize(hash)
      hash['slug'] ||= hash.delete('id') if slugged?
      super(hash)
    end

    def create!
      merge! post("/api/v1/#{self.class.collection_name}.json", {self.class.model_name => to_hash})
    end

    def update!
      update_with! put("/api/v1/#{self.class.collection_name}/#{identifier}.json", {self.class.model_name => to_hash})
    end

    def destroy!
      delete("/api/v1/#{self.class.collection_name}/#{identifier}.json")
    end

    def update_with!(hash)
      self.class.properties.each do |p|
        change = hash[p.to_s]
        self.send("#{p}=", change) if change
      end
      self
    end

    def reload
      update_with! get("/api/v1/#{self.class.collection_name}/#{identifier}.json")
    end

    def identifier
      slugged? ? slug : id
    end

    def slugged?
      respond_to?(:slug)
    end

    def []=(property, value)
      assert_property_required! property, value
      assert_property_exists!(property) rescue return
      super(property.to_s, value)
    end
  end
end
