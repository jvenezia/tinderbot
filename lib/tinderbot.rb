require 'thor'
require 'faraday'
require 'faraday_middleware'
require 'watir-webdriver'
require 'json'

Gem.find_files('tinderbot/**/*.rb').each { |file| require file }