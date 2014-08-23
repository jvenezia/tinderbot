require 'faraday'
require 'faraday_middleware'
require 'watir-webdriver'
require 'json'

require_relative 'lib/facebook_connector'
require_relative 'lib/tinder_connector'

puts 'Getting facebook credentials...'
facebook_authentication_token, facebook_user_id = FacebookConnector.get_facebook_credentials
puts 'Connecting to tinder...'
tinder_connexion = TinderConnector.get_tinder_connexion
TinderConnector.sign_in(tinder_connexion, facebook_authentication_token, facebook_user_id)
puts 'Starting likes...'
TinderConnector.like_people(tinder_connexion)