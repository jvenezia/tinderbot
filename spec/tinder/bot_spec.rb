require 'spec_helper'

describe Tinderbot::Bot do
  let(:tinder_client) { Tinderbot::Client.new }
  let(:tinder_bot) { Tinderbot::Bot.new(tinder_client) }

  describe 'client' do
    it { expect(tinder_bot.client).to eq tinder_client }
  end

  describe '.like_recommended_people' do
    let(:recommended_users) { JSON.parse(open('spec/fixtures/recommended_users.json').read)['results'].each { |user| Tinderbot::Model::User.build_from_tinder_json user } }

    context 'there is no recommended people' do
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return([]) }

      before { expect_any_instance_of(Tinderbot::Client).not_to receive(:like_all) }

      it { tinder_bot.like_recommended_users }
    end

    context 'there is one set of recommended people' do
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return(recommended_users) }
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return([]) }

      before { recommended_users.each { |user| expect_any_instance_of(Tinderbot::Client).not_to receive(:like).with(user).exactly(1).times } }

      it { tinder_bot.like_recommended_users }
    end

    context 'there is two sets of recommended people' do
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return(recommended_users) }
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return(recommended_users) }
      before { expect_any_instance_of(Tinderbot::Client).to receive(:recommended_users).and_return([]) }

      before { recommended_users.each { |user| expect_any_instance_of(Tinderbot::Client).not_to receive(:like).with(user).exactly(2).times } }

      it { tinder_bot.like_recommended_users }
    end
  end
end