# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tinderbot/version'

Gem::Specification.new do |spec|
  spec.name = 'tinderbot'
  spec.version = Tinderbot::VERSION
  spec.authors = ['Jeremy Venezia']
  spec.email = ['veneziajeremy@gmail.com']
  spec.summary = %q{Ruby wrapper for the Tinder API and automatic liker bot.}
  spec.description = %q{Ruby wrapper for the Tinder API and automatic liker bot. }
  spec.homepage = 'https://github.com/jvenezia/tinderbot'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'thor', '~> 0'
  spec.add_dependency 'faraday', '~> 0'
  spec.add_dependency 'faraday_middleware', '~> 0'
  spec.add_dependency 'watir-webdriver', '~> 0'
  spec.add_dependency 'json', '~> 1.8'
end
