module Tinderbot
  module Tinder
    class Bot
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def like_recommended_people
        recommended_people = @client.recommended_users
        while recommended_people
          recommended_people_ids = recommended_people.map {|r| r['_id']}
          @client.like_all recommended_people_ids
          recommended_people = @client.recommended_users
        end
      end
    end
  end
end