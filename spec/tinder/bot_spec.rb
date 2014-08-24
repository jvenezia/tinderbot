require 'spec_helper'

describe Tinderbot::Tinder::Bot do
  let(:tinder_client) { Tinderbot::Tinder::Client.new('', '') }
  before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:sign_in) }
  let(:tinder_bot) { Tinderbot::Tinder::Bot.new(tinder_client) }

  describe 'client' do
    it { expect(tinder_bot.client).to eq tinder_client }
  end

  describe '.like_recommended_people' do
    let(:recommended_people_results) { JSON.parse(open('spec/fixtures/recommended_people.json').read)['results'] }

    context 'there is no recommended people' do
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(nil) }

      before { expect_any_instance_of(Tinderbot::Tinder::Client).not_to receive(:like_all) }

      it { tinder_bot.like_recommended_people }
    end

    context 'there is one set of recommended people' do
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(recommended_people_results) }
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(nil) }

      before { expect_any_instance_of(Tinderbot::Tinder::Client).not_to receive(:like_all).with(recommended_people_results.map { |r| r['_id'] }).exactly(1).times }

      it { tinder_bot.like_recommended_people }
    end

    context 'there is two sets of recommended people' do
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(recommended_people_results) }
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(recommended_people_results) }
      before { expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:get_recommended_people).and_return(nil) }

      before { expect_any_instance_of(Tinderbot::Tinder::Client).not_to receive(:like_all).with(recommended_people_results.map { |r| r['_id'] }).exactly(2).times }

      it { tinder_bot.like_recommended_people }
    end
  end
end