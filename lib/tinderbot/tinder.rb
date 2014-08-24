module Tinderbot
  class Tinder
    LIKED_PEOPLE_LOG_PATH = 'liked_people.log'
    TINDER_API_URL = 'https://api.gotinder.com'
    CONNECTION_USER_AGENT = 'Tinder/3.0.4 (iPhone; iOS 7.1; Scale/2.00)'

    attr_accessor :connection, :liked_people_log_file

    def initialize(facebook_authentication_token, facebook_user_id, options = {})
      build_connection
      sign_in(facebook_authentication_token, facebook_user_id)
      @liked_people_log_file = File.open(LIKED_PEOPLE_LOG_PATH, 'a')
    end

    def get_recommended_people
      JSON.parse(@connection.post('user/recs').body)['results']
    end

    def like_person(person_id)
      @connection.get 'like/' + person_id
      log_liked_person person_id
    end

    def like_people(people)
      people.each do |person|
        person_id = person['_id']
        like_person person_id
        puts person['name']
      end
    end

    def like_recommended_people
      begin
        recommended_people = get_recommended_people
        while recommended_people
          like_people(recommended_people)
          recommended_people = get_recommended_people
        end
      ensure
        @liked_people_log_file.close if liked_people_log_file
      end
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

    def log_liked_person(person_id)
      @liked_people_log_file.write("#{person_id}\n")
    end
  end
end