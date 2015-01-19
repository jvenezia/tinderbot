require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -I lib -r tinderbot.rb'
end