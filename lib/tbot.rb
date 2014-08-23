require 'thor'
require 'faraday'
require 'faraday_middleware'
require 'watir-webdriver'
require 'json'

Gem.find_files('tbot/**/*.rb').each { |file| require file }

module Tbot
  class Application < Thor
    desc 'like', 'Automatically like people.'
    def like
      puts 'Getting facebook credentials...'
      facebook_authentication_token, facebook_user_id = Tbot::FacebookConnector.get_facebook_credentials
      puts 'Connecting to tinder...'
      tinder_connexion = Tbot::TinderConnector.get_tinder_connexion
      Tbot::TinderConnector.sign_in(tinder_connexion, facebook_authentication_token, facebook_user_id)
      puts 'Starting likes...'
      Tbot::TinderConnector.like_people(tinder_connexion)
    end
  end
end
