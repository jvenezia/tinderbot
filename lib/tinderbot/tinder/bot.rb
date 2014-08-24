module Tinderbot
  module Tinder
    class Bot
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def like_recommended_people
        recommended_people = @client.get_recommended_people
        while recommended_people
          recommended_people_ids = recommended_people.map {|r| r['_id']}
          @client.like_people recommended_people_ids
          recommended_people = @client.get_recommended_people
        end
      end
    end
  end
end