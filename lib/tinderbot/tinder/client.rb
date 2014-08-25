module Tinderbot::Tinder
  class Client
    TINDER_API_URL = 'https://api.gotinder.com'
    CONNECTION_USER_AGENT = 'Tinder/3.0.4 (iPhone; iOS 7.1; Scale/2.00)'

    attr_accessor :connection, :logs_enabled

    def initialize(options = {})
      @logs_enabled = options[:logs_enabled]
      build_connection
    end

    def get_authentication_token(facebook_authentication_token, facebook_user_id)
      JSON.parse(@connection.post('/auth', {facebook_token: facebook_authentication_token, facebook_id: facebook_user_id}).body)['token']
    end

    def sign_in(authentication_token)
      @connection.token_auth(authentication_token)
      @connection.headers['X-Auth-Token'] = authentication_token
    end

    def me
      Tinderbot::Tinder::Models::User.build_from_tinder_json JSON.parse(@connection.get('profile').body)
    end

    def user(user_id)
      Tinderbot::Tinder::Models::User.build_from_tinder_json JSON.parse(@connection.get("user/#{user_id}").body)
    end

    def updates
      JSON.parse(@connection.post('updates').body)
    end

    def recommended_users
      JSON.parse(@connection.post('user/recs').body)['results'].map { |r| Tinderbot::Tinder::Models::User.build_from_tinder_json r }
    end

    def like(user_or_user_id)
      if user_or_user_id.is_a? Tinderbot::Tinder::Models::User
        like_from_user_id(user_or_user_id.id)
        puts "Liked #{user_or_user_id.name}" if @logs_enabled
      else
        like_from_user_id(user_or_user_id)
      end
    end

    def like_all(user_ids)
      user_ids.each { |user_id| like user_id }
    end

    def dislike(user_or_user_id)
      if user_or_user_id.is_a? Tinderbot::Tinder::Models::User
        dislike_from_user_id(user_or_user_id.id)
        puts "Disliked #{user_id}" if @logs_enabled
      else
        dislike_from_user_id(user_or_user_id)
      end
    end

    def dislike_all(user_ids)
      user_ids.each { |user_id| dislike user_id }
    end

    def send_message(user_id, message)
      @connection.post("user/matches/#{user_id}", {message: message})
    end

    protected

    def like_from_user_id(user_id)
      @connection.get "like/#{user_id}"
    end

    def dislike_from_user_id(user_id)
      @connection.get "pass/#{user_id}"
    end

    def build_connection
      @connection = Faraday.new(url: TINDER_API_URL) do |faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
      end
      @connection.headers[:user_agent] = CONNECTION_USER_AGENT
    end
  end
end