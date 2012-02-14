module Swiftype
  module Search
    
    VALID_SEARCH_OPTIONS = [:fetch_fields, :search_fields, :filters, :per_page, :page, :document_types]
    VALID_SUGGEST_OPTIONS = [:fetch_fields, :search_fields, :filters, :document_types]

    def parse_search_options(options)
      parse_options(options,VALID_SEARCH_OPTIONS)
    end

    def parse_suggest_options(options)
      parse_options(options,VALID_SUGGEST_OPTIONS)
    end

    def parse_options(options,valid_options)
      parsed_options = {}
      valid_options.each do |option|
        next unless options[option]
        if options[option].instance_of?(Array)
          parsed_options["#{option}[]"] = options[option] 
        elsif options[option].instance_of?(Hash)
          options[option].each { |k,v| parsed_options["#{option}[#{k}]"] = v }
        else
          parsed_options[option] = options[option]
        end
      end
      parsed_options
    end

  end
end
