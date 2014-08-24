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

  describe '.like' do
    let(:person_id) { 'person_id' }

    before { connection.should_receive(:get).with("like/#{person_id}") }

    it { tinder_client.like person_id }
  end

  describe '.like_all' do
    context 'there is no people' do
      let(:people_ids) { [] }

      before { Tinderbot::Tinder::Client.any_instance.should_not_receive(:like) }

      it { tinder_client.like_all people_ids }
    end

    context 'there two people' do
      let(:people_ids) { %w(person_1_id person_2_id) }

      before { people_ids.each { |person_id| Tinderbot::Tinder::Client.any_instance.should_receive(:like).with(person_id) } }

      it { tinder_client.like_all people_ids }
    end
  end

  describe '.dislike' do
    let(:person_id) { 'person_id' }

    before { connection.should_receive(:get).with("pass/#{person_id}") }

    it { tinder_client.dislike person_id }
  end

  describe '.dislike_all' do
    context 'there is no people' do
      let(:people_ids) { [] }

      before { Tinderbot::Tinder::Client.any_instance.should_not_receive(:dislike) }

      it { tinder_client.dislike_all people_ids }
    end

    context 'there two people' do
      let(:people_ids) { %w(person_1_id person_2_id) }

      before { people_ids.each { |person_id| Tinderbot::Tinder::Client.any_instance.should_receive(:dislike).with(person_id) } }

      it { tinder_client.dislike_all people_ids }
    end
  end
end