module Swiftype
  # The Swiftype::ResultSet class represents a {search}[https://swiftype.com/documentation/searching]
  # or {suggest result}[https://swiftype.com/documentation/autocomplete] returned by the Swiftype API.
  class ResultSet
    # @attribute errors [r]
    # a hash of errors for the search (for example filtering on a missing attribute) keyed by DocumentType slug
    attr_reader :errors

    # @attribute records [r]
    # a hash of results for the search keyed by DocumentType slug. Use `[]` to access results more easily.
    attr_reader :records

    # @attribute info [r]
    # a hash of extra query info (for example, facets and number of results) keyed by DocumentType slug.
    # Use the convenience methods of this class for easier access.
    attr_reader :info

    # Create a Swiftype::ResultSet from deserialized JSON.
    def initialize(results)
      @records = results['records']
      @info = results['info']
      @errors = results['errors']
    end

    # Get results for the provided DocumentType
    #
    # @param [String] document_type the DocumentType slug to get results for
    def [](document_type)
      records[document_type]
    end

    # Return a list of DocumentType slugs represented in the ResultSet.
    def document_types
      records.keys
    end

    # Return the search facets for the provided DocumentType. Will be
    # empty unless a facets parameter was provided when calling the
    # search API.
    #
    # @param [String] document_type the DocumentType slug to get facets for
    def facets(document_type)
      info[document_type]['facets']
    end

    # Return the page of results for this ResultSet
    def current_page
      info[info.keys.first]['current_page']
    end

    # Return the number of results per page.
    def per_page
      info[info.keys.first]['per_page']
    end

    # Return the number of pages. Since a search can cover multiple
    # DocumentTypes with different numbers of results, the number of
    # pages can vary between DocumentTypes. With no argument, it
    # returns the maximum num_pages for all DocumentTypes in this
    # ResultSet. With a DocumentType slug, it returns the number of
    # pages for that DocumentType.
    #
    # @param [String] document_type the DocumentType slug to return the number of pages for
    def num_pages(document_type=nil)
      if document_type
        info[document_type]['num_pages']
      else
        info.values.map { |v| v['num_pages'] }.max
      end
    end

    # Return the total number of results for the query
    def total_result_count(document_type)
      info[document_type]['total_result_count']
    end

    # Return the query used for this search
    def query
      info[info.keys.first]['query']
    end
  end
end
