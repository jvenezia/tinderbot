require 'spec_helper'

describe Tinderbot::Tinder::Models::User do
  describe '#build_from_tinder_json' do
    let(:user_tinder_json) { JSON.parse(open('spec/fixtures/user.json').read) }

    subject { Tinderbot::Tinder::Models::User.build_from_tinder_json user_tinder_json }

    it { expect(subject.original_tinder_json).to eq user_tinder_json }
    it { expect(subject.id).to eq user_tinder_json['_id'] }
    it { expect(subject.name).to eq user_tinder_json['name'] }
    it { expect(subject.bio).to eq user_tinder_json['bio'] }
    it { expect(subject.birth_date).to eq Date.parse(user_tinder_json['birth_date']) }
    it { expect(subject.photo_urls).to eq %w(http://images.gotinder.com/user_id/image_1_id.jpg http://images.gotinder.com/user_id/image_2_id.jpg) }

    context 'user is a male' do
      it { expect(subject.gender).to eq :male }
    end

    context 'user is a female' do
      before { user_tinder_json['gender'] = 1 }
      it { expect(subject.gender).to eq :female }
    end
  end
end