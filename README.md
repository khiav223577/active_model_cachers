# ActiveModelCachers

[![Gem Version](https://img.shields.io/gem/v/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Build Status](https://travis-ci.org/khiav223577/active_model_cachers.svg?branch=master)](https://travis-ci.org/khiav223577/active_model_cachers)
[![RubyGems](http://img.shields.io/gem/dt/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Code Climate](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers)
[![Test Coverage](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers/coverage)

Provide cachers to the model so that you could specify which you want to cache. Data will be cached at `Rails.cache` and also at application level via `RequestStore` to cache values between requests. Cachers will maintain cached objects and expire them when they are changed (by update, destroy, and delete).


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

`cache_at(name, query = nil, options = {})`

Specifie a cache on the model. 
 - name: the attribute name.
 - query: how to get data on cache miss. It will be set automatically if the name match an association or an attribute.
 - options: see [here](#options)

### Cache whatever you want

```rb
class User < ActiveRecord::Base
  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }
  cache_at :active_count, ->{ User.active.count }, expire_by: 'User#last_login_at'
end

@count = User.cacher.active_count
```

```rb
class User < ActiveRecord::Base
  cache_at :count, ->{ User.count }, expire_by: 'User', on: [:create, :destroy]
end

@count = User.cacher.count
```

### Cache associations
```rb
class User < ActiveRecord::Base
  has_one :profile
  cache_at :profile
end

@profile = User.cacher_at(profile_id).profile
```

### Cache self
```rb
class User < ActiveRecord::Base
  cache_self
end

@user = User.cacher_at(user_id).self
```


### Cache attributes
```rb
class Profile < ActiveRecord::Base
  cache_at :point
end

@point = Profile.cacher_at(profile_id).point
```

## Options
    
### :expire_by
 
Monitor on the specific model. Clean the cached objects if target are changed.

  - if empty, e.g. `nil` or `''`: Monitoring nothing.
  
  - if string, e.g. `User`: Monitoring all attributes of `User`.
  
  - if string with keyword `#`, e.g. `User#last_login_in_at`: Monitoring only the specific attribute.
 
 ### :on
 
 Fire changes only by a certain action with the `on` option. Like the same option of [after_commit](https://apidock.com/rails/ActiveRecord/Transactions/ClassMethods/after_commit).
 
  - if `:create`: Clean the cache only on new record is created, e.g. `Model.create`.
  
  - if `:update`: Clean the cache only on the record is updated, e.g. `model.update`.
  
  - if `:destroy`: Clean the cache only on the record id destroyed, e.g. `model.destroy`, `model.delete`.
  
  - if `array`, e.g. `[:create, :update]`: Clean the cache by any of specified actions.
 

