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
      puts 'Connecting to tinder...'
      tinder = Tbot::Tinder.new

      puts 'Starting likes...'
      tinder.like_recommended_people
    end
  end
end