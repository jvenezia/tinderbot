require 'faraday'
require 'faraday_middleware'
require 'watir-webdriver'
require 'json'

LIKED_TARGETS_LOG_PATH = 'liked_targets.txt'
FACEBOOK_CREDENTIALS_PATH = 'facebook_credentials.json'

FACEBOOK_AUTHENTICATION_TOKEN_URL = 'https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token'

def get_facebook_credentials
  puts 'Getting facebook credentials...'
  browser = Watir::Browser.new
  browser.goto FACEBOOK_AUTHENTICATION_TOKEN_URL
  facebook_credentials = JSON.parse(File.open(FACEBOOK_CREDENTIALS_PATH).read)
  browser.text_field(id: 'email').when_present.set facebook_credentials['email']
  browser.text_field(id: 'pass').when_present.set facebook_credentials['password']
  browser.button(name: 'login').when_present.click

  facebook_authentication_token = /#access_token=(.*)&expires_in/.match(browser.url).captures[0]

  browser.goto 'https://www.facebook.com/'
  browser.link(title: 'Journal').when_present.click
  facebook_user_id = /fbid=(.*)&set/.match(browser.link(class: 'profilePicThumb').when_present.href).captures[0]

  browser.close
  return facebook_authentication_token, facebook_user_id
end

def get_tinder_connexion
  puts 'Connecting to tinder...'
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

facebook_authentication_token, facebook_user_id = get_facebook_credentials

tinder_connexion = get_tinder_connexion
sign_in(tinder_connexion, facebook_authentication_token, facebook_user_id)

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