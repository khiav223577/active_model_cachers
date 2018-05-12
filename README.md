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

## Cache whatever you want

### Example 1: Cache the number of active user

After specifying the name as `active_count` and how to get data when cache miss by lambda `User.active.count`.
You could access the cached data by calling `active_count` method on the cacher, `User.cacher`.

```rb
class User < ActiveRecord::Base
  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }
  cache_at :active_count, ->{ User.active.count }, expire_by: 'User#last_login_at'
end

@count = User.cacher.active_count
```

You may want to flush cache on the number of active user changed. It can be done by simply setting [expire_by](#expire_by) option. In this case, `User#last_login_at` means flushing the cache when a user's `last_login_at` is changed (whenever by save, update, create, destroy or delete).

### Example 2: Cache the number of user

In this example, the cache should be cleaned on user `destroyed`, or new user `created`, but not on user `updated`. You could specify the cleaning callback to only fire on certain events by [on](#on) option.

```rb
class User < ActiveRecord::Base
  cache_at :count, ->{ User.count }, expire_by: 'User', on: [:create, :destroy]
end

@count = User.cacher.count
```

### Example 3: Access the cacher from a model instance

You could use the cacher from instance scope, e.g. `user.cacher`, instead of `User.cacher`. The difference is that the `binding` of query lambda is changed. In this example, you could write the query as `posts.exists?` in that it's in instance scope, and the binding of the lambda is `user`, not `User`. So that it accesses `posts` method of `user`.

```rb
class User < ActiveRecord::Base
  has_many :posts
  cache_at :has_post?, ->{ posts.exists? }, expire_by: :posts
end

do_something if current_user.cacher.has_post?
```

In this example, the cache should be cleaned when the `posts` of the user changed. You could just set `expire_by` to the association: `:posts`, and then it will do all the works for you magically. (If you want know more details, it actually set `expire_by` to `Post#user_id` and [foreign_key](#foreign_key) option, which is needed for backtracing the user id from post, to `:user_id`)


### Example 4: Pass an argument to the query lambda.

You could cache not only the query result of database but also the result of outer service. Becasue `email_valid?` doesn't match an association or an attribute, by default, the cache will not be cleaned by any changes.

```rb
class User < ActiveRecord::Base
  cache_at :email_valid?, ->(email){ ValidEmail2::Address.new(email).valid_mx? }
end

render_error if not User.cacher_at('pearl@example.com').email_valid?
```

The query lambda can have one parameter, you could pass variable to it by using `cacher_at`. For example, `User.cacher_at(email)`.

```rb
class User < ActiveRecord::Base
  cache_at :email_valid?, ->(email){ ValidEmail2::Address.new(email).valid_mx? }, primary_key: :email
end

render_error if not current_user.cacher.email_valid?
```

It can also be accessed from instance cacher. But you have to set [primary_key](#primary_key), which is needed to know which attribute should be passed to the parameter.

## Convenient syntax sugar for caching ActiveRecord

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

  - if symbol, e.g. `:posts`: Monitoring on the association. It will trying to do all the things for you, including monitoring all attributes of `Post` and set the `foreign_key`.

  - Default value depends on the `name`. If is an association, monitoring the association klass. If is an attribute, monitoring current klass and the attrribute name. If others, monitoring nothing.

### :on

 Fire changes only by a certain action with the `on` option. Like the same option of [after_commit](https://apidock.com/rails/ActiveRecord/Transactions/ClassMethods/after_commit).

  - if `:create`: Clean the cache only on new record is created, e.g. `Model.create`.

  - if `:update`: Clean the cache only on the record is updated, e.g. `model.update`.

  - if `:destroy`: Clean the cache only on the record id destroyed, e.g. `model.destroy`, `model.delete`.

  - if `array`, e.g. `[:create, :update]`: Clean the cache by any of specified actions.

  - Default value is `[:create, :update, :destroy]`

### :foreign_key

This option is needed only for caching assoication and need not to set if [expire_by](#expire_by) option is set to monitor association. Used for backtracing the cache key from cached objects. For examle, if `user` has_many `posts`, and cached the `posts` by user.id. When a post is changed, it needs to know which column to use (in this example, `user_id`) to clean the cache at user.

  - Default value is `:id`

  - Will be automatically determined if [expire_by](#expire_by) option is symbol.

### :primary_key

This option is needed to know which attribute should be passed to the parameter when you are using instance cacher. For example, if a query, named `email_valid?`, uses `user.email` as parameter, and you call it from instnace `user.cacher.email_valid?`. You need to tell it to pass `user.email` instead of `user.id` as the argument.

  - Default value is `:id`



