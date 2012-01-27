require 'active_support/inflector'

module Swiftype
  class BaseModel < OpenStruct
    include Swiftype::Connection
    include Swiftype::Request

    class << self
      attr_reader :parent_classes

      def model_name
        name.split('::').last.underscore
      end

      def collection_name
        model_name.pluralize
      end

      def parents(*parent_classes)
        @parent_classes = parent_classes
      end
    end

    def create!
      update_with! post(path_to_collection, {self.class.model_name => to_hash})
    end

    def update!
      update_with! put(path_to_model, {self.class.model_name => to_hash})
    end

    def destroy!
      delete(path_to_model)
    end

    def path_to_model
      path = (self.class.parent_classes || []).inject("") do |_, parent|
        parent_id = send("#{parent.model_name}_id")
        _ += "#{parent.collection_name}/#{parent_id}/"
        _
      end
      "#{path}#{self.class.collection_name}/#{identifier}.json"
    end

    def path_to_collection
      path = (self.class.parent_classes || []).inject("") do |_, parent|
        parent_id = send("#{parent.model_name}_id")
        _ += "#{parent.collection_name}/#{parent_id}/"
        _
      end
      "#{path}#{self.class.collection_name}.json"
    end

    def update_with!(hash)
      self.class.properties.each do |p|
        change = hash[p.to_s]
        self.send("#{p}=", change) if change
      end
      self
    end

    def reload
      update_with! get(path_to_model)
    end

    def identifier
      slugged? ? slug : id
    end

    def slugged?
      respond_to?(:slug)
    end
  end
end
