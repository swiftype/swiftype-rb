require 'spec_helper'

describe 'deprecated classes and methods' do
  context 'Swiftype::Easy' do
    it 'returns Swiftype::Client' do
      Swiftype::Easy.should == Swiftype::Client
    end
  end

  context 'Swiftype::Easy.configure' do
    it 'calls warn and calls Swiftype.configure' do
      Swiftype::Client.should_receive(:warn)
      Swiftype::Easy.configure do |config|
        config.api_key = 'got set'
      end

      Swiftype.api_key.should == 'got set'
    end
  end
end
