module Tinderbot::Tinder
  class Bot
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def like_recommended_users
      recommended_users = @client.recommended_users
      while recommended_users
        recommended_people_ids = recommended_users.map { |r| r['_id'] }
        @client.like_all recommended_people_ids
        recommended_users = @client.recommended_users
      end
    end
  end
end