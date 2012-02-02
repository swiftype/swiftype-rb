module Swiftype
  class DocumentType < BaseModel
    parents Engine

    def build_document(params={})
      Document.new({
        :document_type_id => id || slug,
        :engine_id => engine_id
      }.merge(params))
    end

    def create_document(params={})
      doc = build_document(params)
      doc.create!
      doc
    end

    def create_documents(documents=[])
      post("engines/#{engine_id}/document_types/#{slug}/documents/bulk_create.json", {:documents => documents})
    end

    def update_documents(documents=[])
      put("engines/#{engine_id}/document_types/#{slug}/documents/bulk_update.json", {:documents => documents})
    end

    def update_document(document={})
      document_id = document[:external_id]
      put("engines/#{engine_id}/document_types/#{slug}/documents/#{document_id}/update_fields", {:fields => document[:fields]})
    end
    
    def destroy_documents(document_ids=[])
      post("engines/#{engine_id}/document_types/#{slug}/documents/bulk_destroy.json", {:documents => document_ids})
    end

    def document(id)
      Document.new get("engines/#{engine_id}/document_types/#{slug}/documents/#{id}.json")
    end

    def engine
      Engine.find(engine_id)
    end

    def documents
      get("engines/#{engine_id}/document_types/#{slug}/documents.json").map { |d| Document.new(d) }
    end

    def suggest(query)
      get("engines/#{engine_id}/document_types/#{slug}/suggest.json", :q => query).map { |d| Document.new(d) }
    end

    def search(query)
      get("engines/#{engine_id}/document_types/#{slug}/search.json", :q => query).map { |d| Document.new(d) }
    end
  end
end
