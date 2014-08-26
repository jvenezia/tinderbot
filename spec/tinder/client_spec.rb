require 'spec_helper'

describe Tinderbot::Tinder::Client do
  let(:tinder_client) { Tinderbot::Tinder::Client.new }
  let(:connection) { tinder_client.connection }

  describe '.connection' do
    it { expect(connection).to be_a(Faraday::Connection) }
    it { expect("#{connection.url_prefix.scheme}://#{connection.url_prefix.host}").to eq(Tinderbot::Tinder::Client::TINDER_API_URL) }
    it { expect(connection.headers[:user_agent]).to eq(Tinderbot::Tinder::Client::CONNECTION_USER_AGENT) }
  end

  describe '.profile' do
    let(:me_tinder_raw_json) { open('spec/fixtures/profile.json').read }

    before { expect(connection).to receive(:get).with('profile').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(me_tinder_raw_json) }

    subject { tinder_client.profile }

    it { should eql? Tinderbot::Tinder::Models::User.build_from_tinder_json(JSON.parse(me_tinder_raw_json)) }
  end

  describe '.user' do
    let(:user_id) { 'user_id' }
    let(:user_tinder_raw_json) { open('spec/fixtures/user.json').read }

    before { expect(connection).to receive(:get).with("user/#{user_id}").and_return(connection) }
    before { expect(connection).to receive(:body).and_return(user_tinder_raw_json) }

    subject { tinder_client.user user_id }

    it { should eql? Tinderbot::Tinder::Models::User.build_from_tinder_json(JSON.parse(user_tinder_raw_json)['results']) }
  end

  describe '.updates' do
    let(:updates_response) { open('spec/fixtures/updates.json').read }

    before { expect(connection).to receive(:post).with('updates').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(updates_response) }

    subject { tinder_client.updates }

    it { should eq JSON.parse(updates_response) }
  end

  describe '.recommended_users' do
    let(:recommended_users_tinder_raw_json) { open('spec/fixtures/recommended_users.json').read }

    before { expect(connection).to receive(:post).with('user/recs').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(recommended_users_tinder_raw_json) }

    subject { tinder_client.recommended_users }

    it { should eql? JSON.parse(recommended_users_tinder_raw_json)['results'].map { |r| Tinderbot::Tinder::Models::User.build_from_tinder_json r } }
  end

  describe '.like' do
    context 'from user id' do
      let(:user_id) { 'user_id' }

      before { expect(connection).to receive(:get).with("like/#{user_id}") }

      it { tinder_client.like user_id }
    end

    context 'from user model' do
      let(:user_tinder_json) { JSON.parse(open('spec/fixtures/user.json').read)['results'] }
      let(:user) { Tinderbot::Tinder::Models::User.build_from_tinder_json user_tinder_json }

      before { expect(connection).to receive(:get).with("like/#{user.id}") }

      it { tinder_client.like user }
    end
  end

  describe '.dislike' do
    context 'from user id' do
      let(:user_id) { 'user_id' }

      before { expect(connection).to receive(:get).with("pass/#{user_id}") }

      it { tinder_client.dislike user_id }
    end

    context 'from user model' do
      let(:user_tinder_json) { JSON.parse(open('spec/fixtures/user.json').read)['results'] }
      let(:user) { Tinderbot::Tinder::Models::User.build_from_tinder_json user_tinder_json }

      before { expect(connection).to receive(:get).with("pass/#{user.id}") }

      it { tinder_client.dislike user }
    end
  end

  describe '.send_message' do
    let(:user_id) { 'user_id' }
    let(:message) { 'message' }

    before { expect(connection).to receive(:post).with("user/matches/#{user_id}", {message: message}) }

    it { tinder_client.send_message user_id, message }
  end
end