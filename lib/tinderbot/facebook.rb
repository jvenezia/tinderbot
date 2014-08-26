module Tinderbot
  class Facebook
    FACEBOOK_AUTHENTICATION_TOKEN_URL = 'https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token'

    def self.get_credentials(facebook_email, facebook_password)
      browser = Watir::Browser.new
      browser.goto FACEBOOK_AUTHENTICATION_TOKEN_URL
      browser.text_field(id: 'email').when_present.set facebook_email
      browser.text_field(id: 'pass').when_present.set facebook_password
      browser.button(name: 'login').when_present.click

      facebook_authentication_token = /#access_token=(.*)&expires_in/.match(browser.url).captures[0]

      browser.goto 'https://www.facebook.com/'
      browser.link(class: 'fbxWelcomeBoxName').when_present.click
      facebook_user_id = /fbid=(.*)&set/.match(browser.link(class: 'profilePicThumb').when_present.href).captures[0]

      browser.close
      return facebook_authentication_token, facebook_user_id
    end
  end
end