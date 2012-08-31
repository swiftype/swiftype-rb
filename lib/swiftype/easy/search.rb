module Swiftype
  class Easy
    module Search
      VALID_SUGGEST_OPTIONS = [:fetch_fields, :search_fields, :filters, :document_types, :functional_boosts, :page, :per_page]
      VALID_SEARCH_OPTIONS =  [:fetch_fields, :search_fields, :filters, :document_types, :functional_boosts, :page, :per_page, :sort_field, :sort_direction]

      def parse_search_options(options)
        parse_options(options, VALID_SEARCH_OPTIONS)
      end

      def parse_suggest_options(options)
        parse_options(options, VALID_SUGGEST_OPTIONS)
      end

      def parse_options(options, valid_options)
        parsed_options = {}
        valid_options.each do |option_name|
          next unless options[option_name]
          parsed_options[option_name] = options[option_name]
        end
        parsed_options
      end
    end
  end
end
