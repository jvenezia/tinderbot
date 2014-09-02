module Tinderbot
  module Model
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

      def to_yaml_properties
        instance_variables - [:@original_tinder_json]
      end

      def ==(other)
        other.class == self.class && other.state == self.state
      end

      protected

      def state
        self.instance_variables.reject { |item| item == :@original_tinder_json }.map { |variable| self.instance_variable_get variable }
      end
    end
  end
end