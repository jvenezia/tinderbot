module Tinderbot
  module Cli
    class Application < Thor
      desc 'like', 'Automatically like people.'

      def like
        puts 'Enter your facebook credentials.'
        facebook_email = ask('Email:')
        facebook_password = ask('Password (typing will be hidden):', echo: false)
        puts "\n"

        puts 'Getting your facebook authentication token...'
        facebook_authentication_token, facebook_user_id = Tinderbot::Facebook.get_credentials(facebook_email, facebook_password)

        puts 'Connecting to tinder...'
        tinder_client = Tinderbot::Tinder::Client.new(facebook_authentication_token, facebook_user_id)

        puts 'Starting likes...'
        tinder_bot = Tinderbot::Tinder::Bot.new tinder_client
        tinder_bot.like_recommended_people
      end
    end
  end
end