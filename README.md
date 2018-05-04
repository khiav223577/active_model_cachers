# ActiveModelCachers

[![Gem Version](https://img.shields.io/gem/v/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Build Status](https://travis-ci.org/khiav223577/active_model_cachers.svg?branch=master)](https://travis-ci.org/khiav223577/active_model_cachers)
[![RubyGems](http://img.shields.io/gem/dt/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Code Climate](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers)
[![Test Coverage](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers/coverage)

Provide cachers to the model so that you could specify which you want to cache. Data will be cached at `Rails.cache` and also application level via `RequestStore` to cache result from backend cache store. Cachers will maintain cached objects and expire them when they are changed (by update, destroy, and delete).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_model_cachers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_model_cachers

### Specify where the cache will be stored

Add the following to your environment files (production.rb, development.rb, test.rb):
```rb
ActiveModelCachers.config do |config|
  config.store = Rails.cache
end
```


## Usage

### Cache whatever you want
```rb
class User < ActiveRecord::Base
  cache_at :user_count_in_country, ->{ User.group(:country).count }
end

cacher = User.cacher_at('Taiwan')
@user_count = cacher.user_count_in_country
```

### Cache associations
```rb
class User < ActiveRecord::Base
  has_one :profile
  cache_at :profile
end

cacher = User.cacher_at(profile_id)
@profile = cacher.profile
```

### Cache self
```rb
class User < ActiveRecord::Base
  cache_self
end

cacher = User.cacher_at(user_id)
@user = cacher.self
```


### Cache attributes
```rb
class Profile < ActiveRecord::Base
  cache_at :point
end

cacher = Profile.cacher_at(profile_id)
@point = cacher.point
```

