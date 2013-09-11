module Swiftype
  class ResultSet
    attr_accessor :records, :info, :errors

    def initialize(results)
      @records = results['records']
      @info = results['info']
      @errors = results['errors']
    end

    def [](document_type)
      records[document_type]
    end

    def document_types
      records.keys
    end

    def facets(document_type)
      info[document_type]['facets']
    end

    def current_page
      info[info.keys.first]['current_page']
    end

    def per_page
      info[info.keys.first]['per_page']
    end

    def num_pages(document_type=nil)
      if document_type
        info[document_type]['num_pages']
      else
        info.values.map { |v| v['num_pages'] }.max
      end
    end

    def total_result_count(document_type)
      info[document_type]['total_result_count']
    end

    def query
      info[info.keys.first]['query']
    end
  end
end
