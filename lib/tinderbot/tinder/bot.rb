module Tinderbot
  module Tinder
    class Bot
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def like_recommended_users
        recommended_users = @client.recommended_users
        while recommended_users
          recommended_users.each { |user| @client.like user }
          recommended_users = @client.recommended_users
        end
      end
    end
  end
end