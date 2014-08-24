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
        facebook_authentication_token, facebook_user_id = Tinderbot::Facebook.get_credentials(options[:facebook_email], options[:facebook_password])

        puts 'Connecting to tinder...'
        tinder = Tinderbot::Tinder.new(facebook_authentication_token, facebook_user_id, facebook_email: facebook_email, facebook_password: facebook_password)

        puts 'Starting likes...'
        tinder.like_recommended_people
      end
    end
  end
end