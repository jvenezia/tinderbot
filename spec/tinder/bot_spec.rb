require 'spec_helper'

describe Tinderbot::Tinder::Bot do
  let(:tinder_client) { Tinderbot::Tinder::Client.new('', '') }
  before { Tinderbot::Tinder::Client.any_instance.should_receive(:sign_in) }

  let(:tinder_bot) { Tinderbot::Tinder::Bot.new(tinder_client) }

  describe 'client' do
    it { expect(tinder_bot.client).to eq tinder_client }
  end

  describe '.like_recommended_people' do
    let(:recommended_people_results) { JSON.parse(open('spec/fixtures/recommended_people.json').read)['results'] }

    context 'there is no recommended people' do
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { nil } }
      before { Tinderbot::Tinder::Client.should_not_receive(:like_people) }

      it { tinder_bot.like_recommended_people }
    end

    context 'there is one set of recommended people' do
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { recommended_people_results } }
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { nil } }

      before { Tinderbot::Tinder::Client.any_instance.should_receive(:like_people).with(recommended_people_results.map { |r| r['_id'] }).exactly(1).times }

      it { tinder_bot.like_recommended_people }
    end

    context 'there is two sets of recommended people' do
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { recommended_people_results } }
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { recommended_people_results } }
      before { Tinderbot::Tinder::Client.any_instance.should_receive(:get_recommended_people) { nil } }

      before { Tinderbot::Tinder::Client.any_instance.should_receive(:like_people).with(recommended_people_results.map { |r| r['_id'] }).exactly(2).times }

      it { tinder_bot.like_recommended_people }
    end
  end
end