require 'spec_helper'

describe 'Configuration' do
  context '.authenticated_url' do
    context 'with non-standard port number' do
      it 'sets the API key and endpoint' do
        Swiftype.authenticated_url = 'http://testkey:@localhost:1234/api/v1'
        Swiftype.api_key.should == 'testkey'
        Swiftype.endpoint.should == 'http://localhost:1234/api/v1/'
      end

      context 'with implicit port number' do
        Swiftype.authenticated_url = 'https://testkey:@api.swiftype.com/api/v1'
        Swiftype.api_key.should == 'testkey'
        Swiftype.endpoint.should == 'https://api.swiftype.com/api/v1/'
      end
    end
  end

  context '.endpoint' do
    context 'with a trailing /' do
      it 'adds / to the end of of the URL' do
        Swiftype.endpoint = 'https://api.swiftype.com/api/v1'
        Swiftype.endpoint.should == 'https://api.swiftype.com/api/v1/'
      end
    end

    context 'with a trailing /' do
      it 'leaves the URL alone' do
        Swiftype.endpoint = 'https://api.swiftype.com/api/v1/'
        Swiftype.endpoint.should == 'https://api.swiftype.com/api/v1/'
      end
    end
  end
end

