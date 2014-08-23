module Tbot
  module Cli
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
end