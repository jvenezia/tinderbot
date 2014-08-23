require 'spec_helper'

describe Tbot::TinderConnector do
  describe '#get_tinder_connexion' do
    let(:connection) { Tbot::TinderConnector.get_tinder_connexion }
    subject { connection }

    it { expect(connection).to be_a(Faraday::Connection) }
    it { expect("#{connection.url_prefix.scheme}://#{connection.url_prefix.host}").to eq(Tbot::TinderConnector::TINDER_API_URL) }
    it { expect(connection.headers[:user_agent]).to eq(Tbot::TinderConnector::CONNECTION_USER_AGENT) }
  end
end