require 'pstore'

module Tinderbot
  module Cli
    class Application < Thor
      FACEBOOK_CREDENTIALS_FILE = 'facebook_credentials.pstore'

      desc 'me', 'Get your profile data.'
      def me
        tinder_client = sign_in
        puts tinder_client.me
      end

      desc 'user USER_ID', 'Get user profile data.'
      def user(user_id)
        tinder_client = sign_in
        puts tinder_client.user user_id
      end

      desc 'updates', 'Get updates'
      def updates
        tinder_client = sign_in
        puts tinder_client.updates
      end

      desc 'recommended', 'Get recommended users.'
      def recommended
        tinder_client = sign_in
        puts tinder_client.recommended_users
      end

      desc 'like USER_ID', 'Like user.'
      def like(user_id)
        tinder_client = sign_in
        puts tinder_client.like user_id
      end

      desc 'dislike USER_ID', 'Dislike user.'
      def dislike(user_id)
        tinder_client = sign_in
        puts tinder_client.dislike user_id
      end

      desc 'send USER_ID MESSAGE', 'Sends message to user'
      def send(user_id, message)
        tinder_client = sign_in
        puts tinder_client.send_message user_id, message
      end

      desc 'autolike', 'Automatically like recommended people. Stops when there is no more people to like.'
      def autolike
        tinder_client = sign_in

        puts 'Starting likes...'
        tinder_bot = Tinderbot::Tinder::Bot.new tinder_client
        tinder_bot.like_recommended_people
      end

      private

      def sign_in
        puts 'Connecting to tinder...'
        tinder_client = Tinderbot::Tinder::Client.new
        store = PStore.new(FACEBOOK_CREDENTIALS_FILE)
        facebook_authentication_token, facebook_user_id = get_last_facebook_credentials(store)
        tinder_authentication_token = get_tinder_authentication_token(store, tinder_client, facebook_authentication_token, facebook_user_id)
        tinder_client.sign_in tinder_authentication_token
        tinder_client
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