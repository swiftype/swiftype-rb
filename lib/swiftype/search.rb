module Swiftype
  module Search
    
    VALID_SEARCH_OPTIONS = [:fetch_fields, :search_fields, :filters, :per_page, :page, :document_types, :functional_boosts]
    VALID_SUGGEST_OPTIONS = [:fetch_fields, :search_fields, :filters, :document_types]

    def parse_search_options(options)
      parse_options(options,VALID_SEARCH_OPTIONS)
    end

    def parse_suggest_options(options)
      parse_options(options,VALID_SUGGEST_OPTIONS)
    end

    def parse_options(options,valid_options)
      parsed_options = {}
      valid_options.each do |option_name|
        next unless options[option_name]        
        encode_single_option(parsed_options,option_name,options[option_name])
      end
      parsed_options
    end
    
    # recursive method to encode arrays, hashes, and values the 'Rails' way, to make server-side parsing simpler
    def encode_single_option(parsed_options,key,value,prefix='')
      prefix = key if prefix.empty?
      if value.instance_of?(Hash)
        value.each { |k,v| encode_single_option(parsed_options,k,v,"#{prefix}[#{k}]") }
      elsif value.instance_of?(Array)
        parsed_options["#{prefix}[]"] = value
      else
        parsed_options["#{prefix}"] = value
      end
    end

  end
end
