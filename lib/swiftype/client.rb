require 'swiftype/configuration'
require 'swiftype/result_set'
require 'swiftype/request'

module Swiftype
  # API client for the {Swiftype API}[https://swiftype.com/documentation/overview].
  class Client
    DEFAULT_TIMEOUT = 15

    include Swiftype::Request

    def self.configure(&block)
      warn "`Swiftype::Easy.configure` has been deprecated. Use `Swiftype.configure` instead."
      Swiftype.configure &block
    end

    # Create a new Swiftype::Client client
    #
    # @param options [Hash] a hash of configuration options that will override what is set on the Swiftype class.
    # @option options [String] :api_key an API Key to use for this client
    # @option options [String] :platform_access_token a user's access token, will be used instead of API key for authenticating requests
    # @option options [Numeric] :overall_timeout overall timeout for requests in seconds (default: 15s)
    # @option options [Numeric] :open_timeout the number of seconds Net::HTTP (default: 15s)
    #   will wait while opening a connection before raising a Timeout::Error

    def initialize(options={})
      @options = options
    end

    def api_key
      @options[:api_key] || Swiftype.api_key
    end

    def platform_access_token
      @options[:platform_access_token]
    end

    def open_timeout
      @options[:open_timeout] || DEFAULT_TIMEOUT
    end

    def overall_timeout
      (@options[:overall_timeout] || DEFAULT_TIMEOUT).to_f
    end

    def wrap(element)
      [element].flatten(1)
    end

    # Methods wrapping the Swiftype private search and API endpoints. Using these methods, you can perform full-text
    # and prefix searches over the Documents in your Engine, in a specific DocumentType, or any subset of DocumentTypes.
    # You can also filter results and get faceted counts for results.
    #
    # For more information, visit the {REST API documentation on searching}[https://swiftype.com/documentation/searching].
    module Search
      # Perform an autocomplete (prefix) search over all the DocumentTypes of the provided engine.
      # This can be used to implement type-ahead autocompletion. However, if your data is not sensitive,
      # you should consider using the {Swiftype public JSONP API}[https://swiftype.com/documentation/public_api]
      # in the user's web browser for suggest queries.
      #
      #     results = client.suggest("swiftype-api-example", "gla")
      #     results['videos'] # => [{'external_id' => 'v1uyQZNg2vE', 'title' => 'How It Feels [through Glass]', ...}, ...]
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] query the search terms
      # @param [Hash] options search options (see {the REST API docs}[https://swiftype.com/documentation/searching] for a complete list)
      # @option options [Integer] :page page number of results to fetch (server defaults to 1)
      # @option options [Integer] :per_page number of results per page (server defaults to 20)
      # @option options [Array] :document_types an array of DocumentType slugs to search.
      #   The server defaults to searching all DocumentTypes in the engine. To search a single document type,
      #   the +suggest_document_type+ method is more convenient.
      # @option options [Hash] :fetch_fields a Hash of DocumentType slug to array of the fields to return with results
      #   (example: <code>{'videos' => ['title', 'channel_id']}</code>)
      # @option options [Hash] :search_fields a Hash of DocumentType slug to array of the fields to search.
      #   May contain {field weight boosts}[https://swiftype.com/documentation/searching#field_weights]
      #   (example: <code>{'videos' => ['title^5', 'tags^2', 'caption']}</code>).
      #   The server defaults to searching all +string+ fields for suggest queries.
      # @option options [Hash] :filters a Hash of DocumentType slug to filter definition Hash.
      #   See {filters in the REST API documentation}[https://swiftype.com/documentation/searching#filters] for more details
      #   (example: <code>{'videos' => {'category_id' => ['23', '25']}}</code>)
      # @option options [Hash] :functional_boosts a Hash of DocumentType slug to {functional boost}[https://swiftype.com/documentation/searching#functional_boosts] definition
      #   (example: <code>{'videos' => {'view_count' => 'logarithmic'}}</code>).
      # @option options [Hash] :sort_field a Hash of DocumentType slug to field name to sort on
      #   (example: <code>{'videos' => 'view_count'}</code>)
      # @option options [Hash] :sort_direction a Hash of DocumentType slug to direction to sort
      #   (example: <code>'videos' => 'desc'</code>). Usually used with +:sort_field+.
      #
      # @return [Swiftype::ResultSet]
      def suggest(engine_id, query, options={})
        search_params = { :q => query }.merge(options)
        response = post("engines/#{engine_id}/suggest.json", search_params)
        ResultSet.new(response)
      end

      # Perform a full-text search over all the DocumentTypes of the provided engine.
      #
      #     results = client.search("swiftype-api-example", "glass")
      #     results['videos'] # => [{'external_id' => 'v1uyQZNg2vE', 'title' => 'How It Feels [through Glass]', ...}, ...]
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] query the search terms (may be nil)
      # @param [Hash] options search options (see {the REST API docs}[https://swiftype.com/documentation/searching] for a complete list)
      # @option options [Integer] :page page number of results to fetch (server defaults to 1)
      # @option options [Integer] :per_page number of results per page (server defaults to 20)
      # @option options [Array] :document_types an array of DocumentType slugs to search.
      #   The server defaults to searching all DocumentTypes in the engine. To search a single document type,
      #   the +search_document_type+ method is more convenient.
      # @option options [Hash] :fetch_fields a Hash of DocumentType slug to array of the fields to return with results
      #   (example: <code>{'videos' => ['title', 'channel_id']}</code>)
      # @option options [Hash] :search_fields a Hash of DocumentType slug to array of the fields to search.
      #   May contain {field weight boosts}[https://swiftype.com/documentation/searching#field_weights]
      #   (example: <code>{'videos' => ['title^5', 'tags^2', 'caption']}</code>).
      #   The server defaults to searching all +string+ and +text+ fields for search queries.
      # @option options [Hash] :filters a Hash of DocumentType slug to filter definition Hash.
      #   See {filters in the REST API documentation}[https://swiftype.com/documentation/searching#filters] for more details
      #   (example: <code>{'videos' => {'category_id' => ['23', '25']}}</code>)
      # @option options [Hash] :functional_boosts a Hash of DocumentType slug to {functional boost}[https://swiftype.com/documentation/searching#functional_boosts] definition
      #   (example: <code>{'videos' => {'view_count' => 'logarithmic'}}</code>).
      # @option options [Hash] :facets a Hash of DocumentType slug to an Array of field names to provide facetted counts for
      #   (example: <code>{'videos' => ['category_id', 'channel_id']}</code>)
      # @option options [Hash] :sort_field a Hash of DocumentType slug to field name to sort on
      #   (example: <code>{'videos' => 'view_count'}</code>)
      # @option options [Hash] :sort_direction a Hash of DocumentType slug to direction to sort
      #   (example: <code>'videos' => 'desc'</code>). Usually used with +:sort_field+.
      #
      # @return [Swiftype::ResultSet]
      def search(engine_id, query, options={})
        search_params = { :q => query }.merge(options)
        response = post("engines/#{engine_id}/search.json", search_params)
        ResultSet.new(response)
      end

      # Perform an autocomplete (prefix) search over a single DocumentType in an Engine.
      # This can be used to implement type-ahead autocompletion. However, if your data is not sensitive,
      # you should consider using the {Swiftype public JSONP API}[https://swiftype.com/documentation/public_api]
      # in the user's web browser for suggest queries.
      #
      #     results = client.suggest_document_type("swiftype-api-example", "videos", "gla")
      #     results['videos'] # => [{'external_id' => 'v1uyQZNg2vE', 'title' => 'How It Feels [through Glass]', ...}, ...]
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] query the search terms
      # @param [Hash] options search options (see {the REST API docs}[https://swiftype.com/documentation/searching] for a complete list)
      # @option options [Integer] :page page number of results to fetch (server defaults to 1)
      # @option options [Integer] :per_page number of results per page (server defaults to 20)
      # @option options [Array] :document_types an array of DocumentType slugs to search.
      #   The server defaults to searching all DocumentTypes in the engine. To search a single document type,
      #   the +suggest_document_type+ method is more convenient.
      # @option options [Hash] :fetch_fields a Hash of DocumentType slug to array of the fields to return with results
      #   (example: <code>{'videos' => ['title', 'channel_id']}</code>)
      # @option options [Hash] :search_fields a Hash of DocumentType slug to array of the fields to search.
      #   May contain {field weight boosts}[https://swiftype.com/documentation/searching#field_weights]
      #   (example: <code>{'videos' => ['title^5', 'tags^2', 'caption']}</code>).
      #   The server defaults to searching all +string+ fields for suggest queries.
      # @option options [Hash] :filters a Hash of DocumentType slug to filter definition Hash.
      #   See {filters in the REST API documentation}[https://swiftype.com/documentation/searching#filters] for more details
      #   (example: <code>{'videos' => {'category_id' => ['23', '25']}}</code>)
      # @option options [Hash] :functional_boosts a Hash of DocumentType slug to {functional boost}[https://swiftype.com/documentation/searching#functional_boosts] definition
      #   (example: <code>{'videos' => {'view_count' => 'logarithmic'}}</code>).
      # @option options [Hash] :sort_field a Hash of DocumentType slug to field name to sort on
      #   (example: <code>{'videos' => 'view_count'}</code>)
      # @option options [Hash] :sort_direction a Hash of DocumentType slug to direction to sort
      #   (example: <code>'videos' => 'desc'</code>). Usually used with +:sort_field+.
      #
      # @return [Swiftype::ResultSet]
      def suggest_document_type(engine_id, document_type_id, query, options={})
        search_params = { :q => query }.merge(options)
        response = post("engines/#{engine_id}/document_types/#{document_type_id}/suggest.json", search_params)
        ResultSet.new(response)
      end

      # Perform a full-text search over a single DocumentType in an Engine.
      #
      #     results = client.search_document_type("swiftype-api-example", "videos", "glass")
      #     results['videos'] # => [{'external_id' => 'v1uyQZNg2vE', 'title' => 'How It Feels [through Glass]', ...}, ...]
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] document_type_id the DocumentType slug or ID
      # @param [String] query the search terms (may be nil)
      # @param [Hash] options search options (see {the REST API docs}[https://swiftype.com/documentation/searching] for a complete list)
      # @option options [Integer] :page page number of results to fetch (server defaults to 1)
      # @option options [Integer] :per_page number of results per page (server defaults to 20)
      # @option options [Hash] :fetch_fields a Hash of DocumentType slug to array of the fields to return with results
      #   (example: <code>{'videos' => ['title', 'channel_id']}</code>)
      # @option options [Hash] :search_fields a Hash of DocumentType slug to array of the fields to search.
      #   May contain {field weight boosts}[https://swiftype.com/documentation/searching#field_weights]
      #   (example: <code>{'videos' => ['title^5', 'tags^2', 'caption']}</code>).
      #   The server defaults to searching all +string+ and +text+ fields for search queries.
      # @option options [Hash] :filters a Hash of DocumentType slug to filter definition Hash.
      #   See {filters in the REST API documentation}[https://swiftype.com/documentation/searching#filters] for more details
      #   (example: <code>{'videos' => {'category_id' => ['23', '25']}}</code>)
      # @option options [Hash] :functional_boosts a Hash of DocumentType slug to {functional boost}[https://swiftype.com/documentation/searching#functional_boosts] definition
      #   (example: <code>{'videos' => {'view_count' => 'logarithmic'}}</code>).
      # @option options [Hash] :facets a Hash of DocumentType slug to an Array of field names to provide facetted counts for
      #   (example: <code>{'videos' => ['category_id', 'channel_id']}</code>)
      # @option options [Hash] :sort_field a Hash of DocumentType slug to field name to sort on
      #   (example: <code>{'videos' => 'view_count'}</code>)
      # @option options [Hash] :sort_direction a Hash of DocumentType slug to direction to sort
      #   (example: <code>'videos' => 'desc'</code>). Usually used with +:sort_field+.
      #
      # @return [Swiftype::ResultSet]
      def search_document_type(engine_id, document_type_id, query, options={})
        search_params = { :q => query }.merge(options)
        response = post("engines/#{engine_id}/document_types/#{document_type_id}/search.json", search_params)
        ResultSet.new(response)
      end
    end

    module User
      # List users for the configured application.
      #
      # @param options [Hash]
      # @option options [Integer] :page page number of users to fetch (server defaults to 1)
      # @option options [Integer] :per_page users to return per page (server defaults to 50)
      def users(options={})
        params = {
          :client_id => Swiftype.platform_client_id,
          :client_secret => Swiftype.platform_client_secret
        }
        get("users.json", params.merge(options))
      end

      # Create a new user for the configured application.
      def create_user
        params = {
          :client_id => Swiftype.platform_client_id,
          :client_secret => Swiftype.platform_client_secret
        }
        post("users.json", params)
      end

      # Return a user created by the configured application.
      #
      # @param user_id [String] the Swiftype User ID
      def user(user_id)
        params = {
          :client_id => Swiftype.platform_client_id,
          :client_secret => Swiftype.platform_client_secret
        }
        get("users/#{user_id}.json", params)
      end
    end

    # An Engine is a search engine that lets you search and filter the Documents it contains.
    # For more information, see the {REST API overview}[https://swiftype.com/documentation/overview].
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
    end

    # Every Document must belong to a DocumentType. For more information, see the {REST API overview}[https://swiftype.com/documentation/overview].
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
    end

    # Documents have fields that can be searched or filtered.
    #
    # For more information on indexing documents, see the {REST API indexing documentation}[https://swiftype.com/documentation/indexing].
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

      def create_or_update_documents_verbose(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_create_or_update_verbose.json", :documents => documents)
      end

      def update_document(engine_id, document_type_id, document_id, fields)
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}/update_fields.json", { :fields => fields })
      end

      def update_documents(engine_id, document_type_id, documents={})
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_update.json", { :documents => documents })
      end

      def async_create_or_update_documents(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/async_bulk_create_or_update.json", :documents => documents)
      end

      # Retrieve Document Receipts from the API by ID
      #
      # @param [Array<String>] receipt_ids an Array of Document Receipt IDs
      #
      # @return [Array<Hash>] an Array of Document Receipt hashes
      def document_receipts(receipt_ids)
        post("document_receipts.json", :ids => receipt_ids)
      end

      # Index a batch of documents using the {asynchronous API}[https://swiftype.com/documentation/asynchronous_indexing].
      # This is a good choice if you have a large number of documents.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] document_type_id the Document Type slug or ID
      # @param [Array] documents an Array of Document Hashes
      # @param [Hash] options additional options
      # @option options [Boolean] :async (false) When true, output is document receipts created. When false, poll until all receipts are no longer pending or timeout is reached.
      # @option options [Numeric] :timeout (10) Number of seconds to wait before raising an exception
      #
      # @return [Array<Hash>] an Array of newly-created Document Receipt hashes if used in :async => true mode
      # @return [Array<Hash>] an Array of processed Document Receipt hashes if used in :async => false mode
      #
      # @raise [Timeout::Error] when used in :async => false mode and the timeout expires
      def index_documents(engine_id, document_type_id, documents = [], options = {})
        documents = wrap(documents)

        res = async_create_or_update_documents(engine_id, document_type_id, documents)

        if options[:async]
          res
        else
          receipt_ids = res["document_receipts"].map { |a| a["id"] }

          poll(options) do
            receipts = document_receipts(receipt_ids)
            flag = receipts.all? { |a| a["status"] != "pending" }
            flag ? receipts : false
          end
        end
      end
    end

    # The analytics API provides a way to export analytics data similar to what is found in the Swiftype Dashboard.
    # See the {REST API Documentation}[https://swiftype.com/documentation/analytics] for details.
    module Analytics
      # Return the number of searches that occurred on each day in the time range for the provided Engine and optional DocumentType.
      # The maximum time range between start and end dates is 30 days.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [Hash] options
      # @option options [String] :document_type_id the DocumentType slug or ID
      # @option options [String] :start_date a date formatted like '2013-01-01'
      # @option options [String] :end_date to a date formatted like '2013-01-01'
      def analytics_searches(engine_id, options={})
        document_type_id = options.delete(:document_type_id)
        if document_type_id
          get("engines/#{engine_id}/document_types/#{document_type_id}/analytics/searches.json", options)
        else
          get("engines/#{engine_id}/analytics/searches.json", options)
        end
      end

      # Return the number of autoselects (when a user clicks a result from an autocomplete dropdown)
      # that occurred on each day in the time range for the provided Engine and optional DocumentType.
      # The maximum time range between start and end dates is 30 days.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [Hash] options
      # @option options [String] :document_type_id the DocumentType slug or ID
      # @option options [String] :start_date a date formatted like '2013-01-01'
      # @option options [String] :end_date to a date formatted like '2013-01-01'
      def analytics_autoselects(engine_id, options={})
        document_type_id = options.delete(:document_type_id)
        if document_type_id
          get("engines/#{engine_id}/document_types/#{document_type_id}/analytics/autoselects.json", options)
        else
          get("engines/#{engine_id}/analytics/autoselects.json", options)
        end
      end

      # Return the number of clickthroughs (when a user clicks a result from a search results page)
      # that occurred on each day in the time range for the provided Engine and optional DocumentType.
      # The maximum time range between start and end dates is 30 days.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [Hash] options
      # @option options [String] :document_type_id the DocumentType slug or ID
      # @option options [String] :start_date a date formatted like '2013-01-01'
      # @option options [String] :end_date to a date formatted like '2013-01-01'
      def analytics_clicks(engine_id, options={})
        document_type_id = options.delete(:document_type_id)
        if document_type_id
          get("engines/#{engine_id}/document_types/#{document_type_id}/analytics/clicks.json", options)
        else
          get("engines/#{engine_id}/analytics/clicks.json", options)
        end
      end

      # Return top queries for an engine.
      #
      # @param [String] engine_id the engine slug or ID
      # @param [Hash] options
      # @option options [String] :start_date a date formatted like '2013-01-01'
      # @option options [String] :end_date a date formatted like '2013-01-01'
      # @option options [Integer] :page page number. The server defaults to page 1 and the maximum is 50.
      # @option options [Integer] :per_page number of results per page. The server defaults to 20 and the maximum is 100.
      def analytics_top_queries(engine_id, options={})
        get("engines/#{engine_id}/analytics/top_queries.json", options)
      end

      # Return top queries with no results for an engine.
      #
      # @param [String] engine_id the engine slug or ID
      # @param [Hash] options
      # @option options [String] :start_date a date formatted like '2013-01-01'
      # @option options [String] :end_date a date formatted like '2013-01-01'
      # @option options [Integer] :page page number. The server defaults to page 1 and the maximum is 50.
      # @option options [Integer] :per_page number of results per page. The server defaults to 20 and the maximum is 100.
      def analytics_top_no_result_queries(engine_id, options={})
        get("engines/#{engine_id}/analytics/top_no_result_queries.json", options)
      end
    end

    # A Domain represents a host in a crawler-based Engine. Domains
    # are only relevant to crawler-base engines, but you can
    # manipulate them through the REST API.
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

      # Trigger a recrawl request for a Domain. Note that this will fail if you have exceeded your recrawl limit.
      def recrawl_domain(engine_id, domain_id)
        put("engines/#{engine_id}/domains/#{domain_id}/recrawl.json")
      end

      # Request to add or update a URL on a Domain. The host of the URL must match the host of the Domain.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] domain_id the Domain ID
      # @param [String] url the URL to crawl
      def crawl_url(engine_id, domain_id, url)
        put("engines/#{engine_id}/domains/#{domain_id}/crawl_url.json", {:url => url})
      end
    end

    # A Clickthrough represents a user clicking on a full-text search result.
    #
    # If you are routing searches through your own server instead of
    # executing them client-side with the Swiftype JavaScript API, you
    # will need to record clickthroughs yourself.
    module Clickthrough
      # Log a clickthrough for a Document.
      #
      # @param [String] engine_id the Engine slug or ID
      # @param [String] document_type the DocumentType slug or ID
      # @param [String] q the query that generated the search result
      # @param [String] id the external_id or ID of the Document
      def log_clickthrough(engine_id, document_type, q, id)
        post(
          "engines/#{engine_id}/document_types/#{document_type}/analytics/log_clickthrough.json",
          {:q => q, :id => id}
        )
      end
    end

    include Swiftype::Client::User
    include Swiftype::Client::Search
    include Swiftype::Client::Engine
    include Swiftype::Client::DocumentType
    include Swiftype::Client::Document
    include Swiftype::Client::Analytics
    include Swiftype::Client::Domain
    include Swiftype::Client::Clickthrough
  end
end
