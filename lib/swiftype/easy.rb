require 'swiftype/easy/version'
require 'swiftype/easy/request'
require 'swiftype/easy/search'

module Swiftype
  class Easy

    include Swiftype::Easy::Request
    include Swiftype::Easy::Search

    def initialize(options={})
    end

    module Configuration
      DEFAULT_ENDPOINT = "http://api.swiftype.com/api/v1/"
      DEFAULT_USER_AGENT = "Swiftype-Easy-Ruby/#{Swiftype::Easy::VERSION}"

      VALID_OPTIONS_KEYS = [
        :username,
        :password,
        :api_key,
        :user_agent,
        :endpoint
      ]

      attr_accessor *VALID_OPTIONS_KEYS

      def self.extended(base)
        base.reset
      end

      def reset
        self.username = nil
        self.password = nil
        self.api_key = nil
        self.endpoint = DEFAULT_ENDPOINT
        self.user_agent = DEFAULT_USER_AGENT
        self
      end

      def configure
        yield self
        self
      end

      def options
        options = {}
        VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
        options
      end
    end

    module Engine
      def engines
        get("engines.json")
      end

      def engine(engine_id)
        get("engines/#{engine_id}.json")
      end

      def create_engine(name)
        post("engines.json", :engine => {:name => name})
      end

      def destroy_engine(engine_id)
        delete("engines/#{engine_id}.json")
      end

      def suggest(engine_id, query, options={})
        search_params = { :q => query }.merge(parse_suggest_options(options))
        response = post("engines/#{engine_id}/suggest.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records }
        results
      end

      def search(engine_id, query, options={})
        search_params = { :q => query }.merge(parse_search_options(options))
        response = post("engines/#{engine_id}/search.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records }
        results
      end
    end

    module DocumentType
      def document_types(engine_id)
        get("engines/#{engine_id}/document_types.json")
      end

      def document_type(engine_id, document_type_id)
        get("engines/#{engine_id}/document_types/#{document_type_id}.json")
      end

      def create_document_type(engine_id, name)
        post("engines/#{engine_id}/document_types.json", :document_type => {:name => name})
      end

      def destroy_document_type(engine_id, document_type_id)
        delete("engines/#{engine_id}/document_types/#{document_type_id}.json")
      end

      def suggest_document_type(engine_id, document_type_id, query, options={})
        search_params = { :q => query }.merge(parse_suggest_options(options))
        response = post("engines/#{engine_id}/document_types/#{document_type_id}/suggest.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records }
        results
      end

      def search_document_type(engine_id, document_type_id, query, options={})
        search_params = { :q => query }.merge(parse_search_options(options))
        response = post("engines/#{engine_id}/document_types/#{document_type_id}/search.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records }
        results
      end
    end

    module Document
      def documents(engine_id, document_type_id, page=nil, per_page=nil)
        options = {}
        options[:page] = page if page
        options[:per_page] = per_page if per_page
        get("engines/#{engine_id}/document_types/#{document_type_id}/documents.json", options)
      end

      def document(engine_id, document_type_id, document_id)
        get("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}.json")
      end

      def create_document(engine_id, document_type_id, document={})
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents.json", :document => document)
      end

      def create_documents(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_create.json", :documents => documents)
      end

      def destroy_document(engine_id, document_type_id, document_id)
        delete("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}.json")
      end

      def destroy_documents(engine_id, document_type_id, document_ids=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_destroy.json", :documents => document_ids)
      end

      def create_or_update_document(engine_id, document_type_id, document={})
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/create_or_update.json", :document => document)
      end

      def create_or_update_documents(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_create_or_update.json", :documents => documents)
      end

      def update_document(engine_id, document_type_id, document_id, fields)
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}/update_fields.json", { :fields => fields })
      end

      def update_documents(engine_id, document_type_id, documents={})
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_update.json", { :documents => documents })
      end
    end

    module Analytics
      def analytics_searches(engine_id, from=nil, to=nil)
        options = {}
        options[:start_date] = from if from
        options[:end_date] = to if to
        get("engines/#{engine_id}/analytics/searches.json", options)
      end

      def analytics_autoselects(engine_id, from=nil, to=nil)
        options = {}
        options[:start_date] = from if from
        options[:end_date] = to if to
        get("engines/#{engine_id}/analytics/autoselects.json", options)
      end

      def analytics_top_queries(engine_id, page=nil, per_page=nil)
        options = {}
        options[:page] = page if page
        options[:per_page] = per_page if per_page
        get("engines/#{engine_id}/analytics/top_queries.json", options)
      end
    end

    module Domain
      def domains(engine_id)
        get("engines/#{engine_id}/domains.json")
      end

      def domain(engine_id, domain_id)
        get("engines/#{engine_id}/domains/#{domain_id}.json")
      end

      def create_domain(engine_id, url)
        post("engines/#{engine_id}/domains.json", {:domain => {:submitted_url => url}})
      end

      def destroy_domain(engine_id, domain_id)
        delete("engines/#{engine_id}/domains/#{domain_id}.json")
      end

      def recrawl_domain(engine_id, domain_id)
        put("engines/#{engine_id}/domains/#{domain_id}/recrawl.json")
      end

      def crawl_url(engine_id, domain_id, url)
        put("engines/#{engine_id}/domains/#{domain_id}/crawl_url.json", {:url => url})
      end
    end

    extend Swiftype::Easy::Configuration
    include Swiftype::Easy::Engine
    include Swiftype::Easy::DocumentType
    include Swiftype::Easy::Document
    include Swiftype::Easy::Analytics
    include Swiftype::Easy::Domain
  end
end
