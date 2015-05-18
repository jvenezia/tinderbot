module Tinderbot
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

    def profile
      Tinderbot::Model::User.build_from_tinder_json JSON.parse(@connection.get('profile').body)
    end

    def user(user_id)
      Tinderbot::Model::User.build_from_tinder_json JSON.parse(@connection.get("user/#{user_id}").body)['results']
    end

    def updates
      JSON.parse(@connection.post('updates').body)
    end

    def recommended_users
      json_results = JSON.parse(@connection.post('user/recs').body)['results']
      json_results = json_results.map { |r| Tinderbot::Model::User.build_from_tinder_json r unless r['name'] == 'Tinder Team'}.compact if json_results
      (json_results.empty? if json_results) ? nil : json_results
    end

    def like(user_or_user_id)
      if user_or_user_id.is_a? Tinderbot::Model::User
        like_from_user_id(user_or_user_id.id)
        puts "Liked #{user_or_user_id.id} (#{user_or_user_id.name})" if @logs_enabled
      else
        like_from_user_id(user_or_user_id)
        puts "Liked #{user_or_user_id}" if @logs_enabled
      end
    end

    def dislike(user_or_user_id)
      if user_or_user_id.is_a? Tinderbot::Model::User
        dislike_from_user_id(user_or_user_id.id)
        puts "Disliked #{user_or_user_id.id} (#{user_or_user_id.name})" if @logs_enabled
      else
        dislike_from_user_id(user_or_user_id)
        puts "Disliked #{user_or_user_id}" if @logs_enabled
      end
    end

    def remove(user_or_user_id)
      if user_or_user_id.is_a? Tinderbot::Model::User
        remove_from_user_id(user_or_user_id.id)
        puts "Removed #{user_or_user_id.id} (#{user_or_user_id.name})" if @logs_enabled
      else
        remove_from_user_id(user_or_user_id)
        puts "Removed #{user_or_user_id}" if @logs_enabled
      end
    end

    def send_message(user_id, message)
      @connection.post("user/matches/#{user_id}", {message: message})
      puts "Sent message to #{user_id}" if @logs_enabled
    end

    def update_location(location)
      latitude = location.split(',')[0]
      longitude = location.split(',')[1]

      if latitude && longitude
        result = JSON.parse(@connection.post('user/ping', {lat: latitude, lon: longitude}).body)

        if result['status'] == 200
          puts "Location has been updated to #{location}" if @logs_enabled
        else
          puts result['error'] if @logs_enabled
        end
      else
        raise Tinderbot::Error, 'Invalid location provided'
      end
    end

    protected

    def like_from_user_id(user_id)
      @connection.get "like/#{user_id}"
    end

    def dislike_from_user_id(user_id)
      @connection.get "pass/#{user_id}"
    end

    def remove_from_user_id(user_id)
      @connection.delete "user/matches/#{user_id}"
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
