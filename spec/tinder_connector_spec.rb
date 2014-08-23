require 'spec_helper'

describe Tinderbot::Tinder do
  let(:tinder_connector) { Tinderbot::Tinder.new }
  before { Tinderbot::Facebook.should_receive(:get_credentials) }
  before { Tinderbot::Tinder.any_instance.should_receive(:sign_in) }

  describe '.connection' do
    let(:connection) { tinder_connector.connection }

    it { expect(connection).to be_a(Faraday::Connection) }
    it { expect("#{connection.url_prefix.scheme}://#{connection.url_prefix.host}").to eq(Tinderbot::Tinder::TINDER_API_URL) }
    it { expect(connection.headers[:user_agent]).to eq(Tinderbot::Tinder::CONNECTION_USER_AGENT) }
  end

  describe '.like_people' do
    let(:recommended_people) { JSON.parse(open('spec/fixtures/recommended_people.json').read) }

    before { Tinderbot::Tinder.any_instance.should_receive(:like_person).exactly(recommended_people.count).times }

    it { tinder_connector.like_people recommended_people }
  end

  describe '.like_recommended_people' do
    let(:recommended_people) { JSON.parse(open('spec/fixtures/recommended_people.json').read) }

    context 'there is no recommended people' do
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { nil } }
      before { Tinderbot::Tinder.should_not_receive(:like_people) }

      it { tinder_connector.like_recommended_people }
    end

    context 'there is one set of recommended people' do
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { recommended_people } }
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { nil } }

      before { Tinderbot::Tinder.any_instance.should_receive(:like_people).exactly(1).times }

      it { tinder_connector.like_recommended_people }
    end

    context 'there is two sets of recommended people' do
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { recommended_people } }
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { recommended_people } }
      before { Tinderbot::Tinder.any_instance.should_receive(:get_recommended_people) { nil } }

      before { Tinderbot::Tinder.any_instance.should_receive(:like_people).exactly(2).times }

      it { tinder_connector.like_recommended_people }
    end
  end
end