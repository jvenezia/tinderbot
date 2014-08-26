# Tinderbot

[![Build](https://travis-ci.org/jvenezia/tinderbot.svg?branch=master)](https://travis-ci.org/jvenezia/tinderbot)
[![Gem Version](https://badge.fury.io/rb/tinderbot.svg)](http://badge.fury.io/rb/tinderbot)

Tinderbot is a ruby wrapper for the Tinder API.

It also contains a bot which automatically like recommended people.

It can be used in ruby, or in command line.

## Installation

Add this line to your application's Gemfile:

    gem 'tinderbot'

Or install it yourself as:

    $ gem install tinderbot


## Getting your facebook authentication token

You'll need to supply a facebook authentication token and an associated facebook id.

You can get those manually by getting to this link:  
https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token  
Sign in, then pick up your authentication token from the **access_token** param in the url.  
Get your facebook user id with this [online tool](http://findmyfacebookid.com/) by providing your profile url.

Tinderbot also provides a script to get your facebook credentials.
```ruby
facebook_email = 'your facebook email'
facebook_password = 'your facebook password'

facebook_authentication_token, facebook_user_id = Tinderbot::Facebook.get_credentials(facebook_email, facebook_password)
```

## Usage
### Authenticating

Once you get your credentials, you can sign in to Tinder.
```ruby
facebook_authentication_token = 'your facebook authentication token'
facebook_user_id = 'your facebook user id'

tinder_client = Tinderbot::Tinder::Client.new
tinder_authentication_token = tinder_client.get_authentication_token(facebook_authentication_token, facebook_user_id)
tinder_client.sign_in tinder_authentication_token
```

### Interacting with the Tinder API
```ruby
user = tinder_client.me #=> returns an instance of Tinderbot::Tinder::Models::User
user.original_tinder_json #=> {...} original json from tinder's API
user.id #=> 1234
user.name #=> 'Bob'
user.bio #=> 'I am awesome'
user.birth_date #=> #<Date: 2014-05-01> 
user.gender #=> :male (or :female)
user.photo_urls #=> ['http://photo_1_url.jpg', 'http://photo_2_url.jpg']

user = tinder_client.user(user_id) #=> returns a Tinderbot::Tinder::Models::User object

users = tinder_client.recommended_users #=> returns an array of Tinderbot::Tinder::Models::User instances

tinder_client.updates #=> {...} original json from tinder's API

tinder_client.send_message(user_id, message)

# you can provide a user instance or a user id to like or dislike users
tinder_client.like(user)
tinder_client.like(user.id)
tinder_client.dislike(user)
tinder_client.dislike(user.id)
```

### Using the bot
Tinderbot provides a simple bot which automatically likes all recommended people. It stops when there is no more recommended people.
```ruby
tinder_bot = Tinderbot::Tinder::Bot.new tinder_client
tinder_bot.like_recommended_users
```

### Using the command line tool
You can interact with Tinderbot with command lines.
```
> tinderbot
Commands:
  tinderbot autolike              # Automatically like recommended people (Stops when there is no more people to like)
  tinderbot dislike USER_ID       # Dislike user
  tinderbot help [COMMAND]        # Describe available commands or one specific command
  tinderbot like USER_ID          # Like user
  tinderbot me                    # Get your profile data
  tinderbot recommended           # Get recommended users
  tinderbot send USER_ID MESSAGE  # Send message to user
  tinderbot updates               # Get updates
  tinderbot user USER_ID          # Get user profile data
```

## Contributing
Feel free to contribute!

1. Fork it ( https://github.com/jvenezia/tinderbot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License
Released under the MIT License, which can be found in `LICENSE.txt`.