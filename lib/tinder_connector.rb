require_relative 'utils'

class TinderConnector
  LIKED_PEOPLE_LOG_PATH = 'liked_people.txt'
  TINDER_API_URL = 'https://api.gotinder.com'

  def self.get_tinder_connexion
    Faraday.new(url: TINDER_API_URL) do |faraday|
      faraday.request :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.sign_in(tinder_connexion, facebook_authentication_token, facebook_user_id)
    authentication_response = JSON.parse(tinder_connexion.post('/auth', {facebook_token: facebook_authentication_token, facebook_id: facebook_user_id}).body)
    tinder_authentication_token = authentication_response['token']
    tinder_connexion.token_auth(tinder_authentication_token)
    tinder_connexion.headers['X-Auth-Token'] = tinder_authentication_token
  end

  def self.get_new_recommended_people_set(tinder_connexion)
    JSON.parse(tinder_connexion.post('user/recs').body)['results']
  end

  def self.like_people(tinder_connexion)
    begin
      liked_people_log_file = File.open(LIKED_PEOPLE_LOG_PATH, 'a')
      recommended_people_set = get_new_recommended_people_set(tinder_connexion)
      liked_person_count = 0
      while recommended_people_set
        recommended_people_set.each do |person|
          Utils.human_sleep
          person_id = person['_id']
          tinder_connexion.get 'like/' + person_id
          liked_people_log_file.write("#{person_id}\n")
          liked_person_count += 1
          puts person['name']
        end
        recommended_people_set = get_new_recommended_people_set(tinder_connexion)
      end
    ensure
      puts "\nLiked #{liked_person_count} people."
      liked_people_log_file.close if liked_people_log_file
    end
  end
end