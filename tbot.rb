require 'faraday'
require 'faraday_middleware'
require 'json'

LIKED_TARGETS_LOG_PATH = 'liked_targets.txt'
FACEBOOK_CREDENTIALS_PATH = 'facebook_credentials.json'

def get_tinder_connexion
  puts 'Connecting...'
  Faraday.new(url: 'https://api.gotinder.com') do |faraday|
    faraday.request :json
    faraday.adapter Faraday.default_adapter
  end
end

def sign_in(tinder_connexion, facebook_authentication_token, facebook_user_id)
  authentication_response = JSON.parse(tinder_connexion.post('/auth', {facebook_token: facebook_authentication_token, facebook_id: facebook_user_id}).body)
  tinder_authentication_token = authentication_response['token']

  tinder_connexion.token_auth(tinder_authentication_token)
  tinder_connexion.headers['X-Auth-Token'] = tinder_authentication_token
end

facebook_credentials = JSON.parse(File.open(FACEBOOK_CREDENTIALS_PATH).read)
tinder_connexion = get_tinder_connexion
sign_in(tinder_connexion, facebook_credentials['authentication_token'], facebook_credentials['user_id'])

puts 'Fetching targets...'
begin
  liked_targets_log_file = File.open(LIKED_TARGETS_LOG_PATH, 'a')
  recommended_targets = JSON.parse(tinder_connexion.post('user/recs').body)
  liked_targets_count = 0
  while recommended_targets['results']
    puts 'Liking...'
    recommended_targets['results'].each do |target|
      target_id = target['_id']
      liked_targets_log_file.write("#{target_id}\n")
      tinder_connexion.get 'like/' + target_id
      liked_targets_count += 1

      p "Liked #{target['name']}."
    end
    recommended_targets = JSON.parse(tinder_connexion.post('user/recs').body)
  end
  puts "\nLiked #{liked_targets_count} target(s)."
ensure
  puts 'Ending...'
  liked_targets_log_file.close if liked_targets_log_file
end