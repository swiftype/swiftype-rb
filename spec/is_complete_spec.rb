require 'spec_helper'
require 'uri'

describe Swiftype::Easy do
  context 'Swiftype Easy Client' do
    it 'has all supported API methods implemented' do
      uri = URI.parse(ENV['API_HOST'])
      uri.path = ''
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.should be_kind_of Net::HTTPSuccess
    end
  end
end
