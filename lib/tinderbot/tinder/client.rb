module Tinderbot
  module Tinder
    class Client
      TINDER_API_URL = 'https://api.gotinder.com'
      CONNECTION_USER_AGENT = 'Tinder/3.0.4 (iPhone; iOS 7.1; Scale/2.00)'

      attr_accessor :connection

      def initialize(facebook_authentication_token, facebook_user_id)
        build_connection
        sign_in(facebook_authentication_token, facebook_user_id)
      end

      def get_recommended_people
        JSON.parse(@connection.post('user/recs').body)['results']
      end

      def like(person_id)
        @connection.get "like/#{person_id}"
      end

      def like_all(people_ids)
        people_ids.each { |person_id| like person_id }
      end

      def dislike(person_id)
        @connection.get "pass/#{person_id}"
      end

      def dislike_all(people_ids)
        people_ids.each { |person_id| dislike person_id }
      end

      protected

      def build_connection
        @connection = Faraday.new(url: TINDER_API_URL) do |faraday|
          faraday.request :json
          faraday.adapter Faraday.default_adapter
        end
        @connection.headers[:user_agent] = CONNECTION_USER_AGENT
      end

      def sign_in(facebook_authentication_token, facebook_user_id)
        authentication_response = JSON.parse(@connection.post('/auth', {facebook_token: facebook_authentication_token, facebook_id: facebook_user_id}).body)
        tinder_authentication_token = authentication_response['token']
        @connection.token_auth(tinder_authentication_token)
        @connection.headers['X-Auth-Token'] = tinder_authentication_token
      end
    end
  end
end