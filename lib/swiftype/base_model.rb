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

    def id
      self._id
    end

    def to_hash
      table
    end

    def to_json
      to_hash.to_json
    end

    def create!
      update_with! post(path_to_collection, {self.class.model_name => to_hash})
    end

    def update!
      update_with! put(path_to_model, {self.class.model_name => to_hash})
    end

    def destroy!
      !!delete(path_to_model)
    end

    def path_to_model
      "#{raw_path_to_model}.json"
    end

    def raw_path_to_model
      path = (self.class.parent_classes || []).inject("") do |_, parent|
        parent_id = send("#{parent.model_name}_id")
        _ += "#{parent.collection_name}/#{parent_id}/"
        _
      end
      "#{path}#{self.class.collection_name}/#{identifier}"
    end

    def path_to_collection
      "#{raw_path_to_collection}.json"
    end

    def raw_path_to_collection
      path = (self.class.parent_classes || []).inject("") do |_, parent|
        parent_id = send("#{parent.model_name}_id")
        _ += "#{parent.collection_name}/#{parent_id}/"
        _
      end
      "#{path}#{self.class.collection_name}"
    end

    def update_with!(hash)
      hash.each do |k, v|
        send "#{k}=", v
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
