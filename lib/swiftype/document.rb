module Swiftype
  class Document < BaseModel
    parents Engine, DocumentType

    def engine
      Engine.find engine_id
    end

    def document_type
      DocumentType.find document_type_id
    end

    def update_fields!(hash)
      update_with! put("#{raw_path_to_model}/update_fields", {:fields => hash})
    end
  end
end
