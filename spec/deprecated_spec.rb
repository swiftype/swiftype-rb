require 'spec_helper'

describe 'deprecated classes and methods' do
  context 'Swiftype::Easy' do
    it 'returns Swiftype::Client' do
      expect(Swiftype::Easy).to eq(Swiftype::Client)
    end
  end

  context 'Swiftype::Easy.configure' do
    it 'calls warn and calls Swiftype.configure' do
      expect(Swiftype::Client).to receive(:warn)
      Swiftype::Easy.configure do |config|
        config.api_key = 'got set'
      end

      expect(Swiftype.api_key).to eq('got set')
    end
  end
end
