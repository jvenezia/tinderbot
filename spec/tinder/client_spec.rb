require 'spec_helper'

describe Tinderbot::Tinder::Client do
  let(:tinder_client) { Tinderbot::Tinder::Client.new('', '') }
  before { Tinderbot::Tinder::Client.any_instance.should_receive(:sign_in) }
  let(:connection) { tinder_client.connection }

  describe '.connection' do
    it { expect(connection).to be_a(Faraday::Connection) }
    it { expect("#{connection.url_prefix.scheme}://#{connection.url_prefix.host}").to eq(Tinderbot::Tinder::Client::TINDER_API_URL) }
    it { expect(connection.headers[:user_agent]).to eq(Tinderbot::Tinder::Client::CONNECTION_USER_AGENT) }
  end

  describe '.get_recommended_people' do
    let(:recommended_people_response) { open('spec/fixtures/recommended_people.json').read }

    before { connection.should_receive(:post).with('user/recs') { connection } }
    before { connection.should_receive(:body) { recommended_people_response } }

    subject { tinder_client.get_recommended_people }

    it { should eq JSON.parse(recommended_people_response)['results'] }
  end

  describe '.like_person' do
    let(:person_id) { 'person_id' }

    before { connection.should_receive(:get).with("like/#{person_id}") }

    it { tinder_client.like_person person_id }
  end

  describe '.like_people' do
    context 'there is no people' do
      let(:people_ids) { [] }

      before { Tinderbot::Tinder::Client.any_instance.should_not_receive(:like_person) }

      it { tinder_client.like_people people_ids }
    end

    context 'there two people' do
      let(:people_ids) { %w(person_1_id person_2_id) }

      before { people_ids.each { |person_id| Tinderbot::Tinder::Client.any_instance.should_receive(:like_person).with(person_id) } }

      it { tinder_client.like_people people_ids }
    end
  end

  # describe '.like_people' do
  #   let(:recommended_people) { JSON.parse(open('spec/fixtures/recommended_people.json').read) }
  #
  #   before { Tinderbot::Tinder.any_instance.should_receive(:like_person).exactly(recommended_people.count).times }
  #
  #   it { tinder_client.like_people recommended_people }
  # end
end