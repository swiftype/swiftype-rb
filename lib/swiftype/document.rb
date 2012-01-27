module Swiftype
  class Document < BaseModel
    parents Engine, DocumentType

    def engine
      Engine.find engine_id
    end

    def document_type
      DocumentType.find document_type_id
    end
  end
end
