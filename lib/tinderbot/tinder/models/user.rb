module Tinderbot
  module Tinder
    module Models
      class User
        attr_accessor :original_tinder_json, :id, :name, :bio, :birth_date, :gender, :photo_urls

        def self.build_from_tinder_json(tinder_json)
          user = self.new
          user.original_tinder_json = tinder_json
          user.id = tinder_json['_id']
          user.name = tinder_json['name']
          user.bio = tinder_json['bio']
          user.birth_date = Date.parse tinder_json['birth_date']
          user.gender = tinder_json['gender'] == 0 ? :male : :female
          user.photo_urls = tinder_json['photos'].map { |t| t['url'] }
          user
        end
      end
    end
  end
end