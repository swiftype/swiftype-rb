require 'spec_helper'

describe Swiftype::SSO do
  let(:user_id) { '5064a7de2ed960e715000276' }
  let(:timestamp) { 1379382520 }
  before :each do
    Swiftype.platform_client_id = '3e4fd842fc99aecb4dc50e5b88a186c1e206ddd516cdd336da3622c4afd7e2e9'
    Swiftype.platform_client_secret = '4441879b5e2a9c3271f5b1a4bc223b715f091e5ed20fe75d1352e1290c7a6dfb'

    allow_any_instance_of(Time).to receive(:to_i).and_return(timestamp)
  end

  context '.token' do
    it 'generates an SSO token' do
      expect(Swiftype::SSO.token(user_id, timestamp)).to eq('81033d182ad51f231cc9cda9fb24f2298a411437')
    end
  end

  context '.url' do
    it 'generates an SSO URL' do
      expect(Swiftype::SSO.url(user_id)).to eq('https://swiftype.com/sso?user_id=5064a7de2ed960e715000276&client_id=3e4fd842fc99aecb4dc50e5b88a186c1e206ddd516cdd336da3622c4afd7e2e9&timestamp=1379382520&token=81033d182ad51f231cc9cda9fb24f2298a411437')
    end
  end
end
