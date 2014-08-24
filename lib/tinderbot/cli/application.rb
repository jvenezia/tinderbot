require 'pstore'

module Tinderbot
  module Cli
    class Application < Thor
      FACEBOOK_CREDENTIALS_FILE = 'facebook_credentials.pstore'

      desc 'like', 'Automatically like people.'
      def like
        puts 'Connecting to tinder...'
        tinder_client = Tinderbot::Tinder::Client.new
        sign_in(tinder_client)

        puts 'Starting likes...'
        tinder_bot = Tinderbot::Tinder::Bot.new tinder_client
        tinder_bot.like_recommended_people
      end

      private

      def sign_in(tinder_client)
        store = PStore.new(FACEBOOK_CREDENTIALS_FILE)
        facebook_authentication_token, facebook_user_id = get_last_facebook_credentials(store)
        tinder_authentication_token = get_tinder_authentication_token(store, tinder_client, facebook_authentication_token, facebook_user_id)
        tinder_client.sign_in tinder_authentication_token
      end

      def get_tinder_authentication_token(store, tinder_client, facebook_authentication_token, facebook_user_id)
        tinder_authentication_token = tinder_client.get_authentication_token(facebook_authentication_token, facebook_user_id)
        unless tinder_authentication_token
          facebook_authentication_token, facebook_user_id = get_facebook_credentials
          store_facebook_credentials(store, facebook_authentication_token, facebook_user_id)
          tinder_authentication_token = tinder_client.get_authentication_token(facebook_authentication_token, facebook_user_id)
        end
        tinder_authentication_token
      end

      def get_facebook_credentials
        puts 'Enter your facebook credentials.'
        facebook_email = ask('Email:')
        facebook_password = ask('Password (typing will be hidden):', echo: false)
        puts "\n"

        puts 'Getting your facebook authentication token...'
        facebook_authentication_token, facebook_user_id = Tinderbot::Facebook.get_credentials(facebook_email, facebook_password)
        return facebook_authentication_token, facebook_user_id
      end

      def get_last_facebook_credentials(store)
        facebook_authentication_token = store.transaction { store[:facebook_authentication_token] }
        facebook_user_id = store.transaction { store[:facebook_user_id] }
        return facebook_authentication_token, facebook_user_id
      end

      def store_facebook_credentials(store, facebook_authentication_token, facebook_user_id)
        store.transaction do
          store[:facebook_authentication_token] = facebook_authentication_token
          store[:facebook_user_id] = facebook_user_id
        end
      end
    end
  end
end