# :stopdoc:

# Stolen from ruby core's uri/common.rb, with modifications to support 1.8.x
#
# https://github.com/ruby/ruby/blob/trunk/lib/uri/common.rb
#
#

module URI
  def self.encode_www_form(enum)
    enum.map do |k,v|
      if v.nil?
        encode_www_form_component(k)
      elsif v.respond_to?(:to_ary)
        v.to_ary.map do |w|
          str = encode_www_form_component(k)
          unless w.nil?
            str << '='
            str << encode_www_form_component(w)
          end
        end.join('&')
      else
        str = encode_www_form_component(k)
        str << '='
        str << encode_www_form_component(v)
      end
    end.join('&')
  end

  def self.encode_www_form_component(str)
    str.to_s.gsub(/[^*\-.0-9A-Z_a-z]/) { |chr| TBLENCWWWCOMP_[chr] }
  end
end
