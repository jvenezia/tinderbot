require 'thor'
require 'faraday'
require 'faraday_middleware'
require 'watir-webdriver'
require 'json'

Gem.find_files('tbot/**/*.rb').each { |file| require file }

module Tbot
end