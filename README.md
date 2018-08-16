# ActiveModelCachers

[![Gem Version](https://img.shields.io/gem/v/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Build Status](https://travis-ci.org/khiav223577/active_model_cachers.svg?branch=master)](https://travis-ci.org/khiav223577/active_model_cachers)
[![RubyGems](http://img.shields.io/gem/dt/active_model_cachers.svg?style=flat)](http://rubygems.org/gems/active_model_cachers)
[![Code Climate](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers)
[![Test Coverage](https://codeclimate.com/github/khiav223577/active_model_cachers/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/active_model_cachers/coverage)

ActiveModelCachers provides cachers to models and allows the users to specify what needs to be cached. The data will be cached at `Rails.cache` and also at application level via `RequestStore`, to cache values between requests. The cachers will maintain cached objects and expire them when they are changed (e.g. created, updated, destroyed, or deleted).

ActiveModelCachers:

- Uses multiple levels of cache ([Multi-level Cache](#multi-level-cache))
- Does not pollute the original ActiveModel API
- Supports ActiveRecord 3, 4 and 5
- Has high test coverage

### Table of contents 

1. [Compare with identity_cache](#compare-with-identity_cache)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Examples](#examples)
5. [Smart Caching](#smart-caching)
6. [Convenient syntax sugar for caching ActiveRecord](#convenient-syntax-sugar-for-caching-activerecord)
7. [Options](#options)
8. [Future Works](#future-works)
9. [Development](#development)
10. [Contributing](#contributing)
11. [License](#license)

## Compare with [identity_cache](https://github.com/Shopify/identity_cache)

`active_model_cachers` allows you to specify what to cache and when to expire those caches, so that you can cache raw sql query results, time-consuming methods, responses of requests, and so on. It also supports AR associations/attributes (has_many, has_one, belongs_to) and secondary indexes.

`identity_cache` focuses on AR, and doesn't have the flexibility to specify the query.`identity_cache` has more features for caching AR associations/attributes. Some of these feature are: Caching attributes by multiple keys, embedding associations to load data in one fetch, non-unique secondary indexes, and caching polymorphic associations.

Another important difference is that `active_model_cachers` encapsulates methods to `cacher`, while `identity_cache` adds a number of `fetch_*` method to `AR` directly, therefore it's more possible to have method name collision when using `identity_cache`.

## Installation

To install active_model_cachers, add this line to your application's Gemfile:

```ruby
gem 'active_model_cachers'
```

Then execute:

    $ bundle

Or install it yourself by executing:

    $ gem install active_model_cachers

Add an initializer with this code to your project:

```rb
ActiveModelCachers.config do |config|
  config.store = Rails.cache # specify where the cache will be stored
end
```

## Usage

### The `cache_at` method

Use the `cache_at` method to cache whatever you want. Specify a cache on the model:

`cache_at(name, query = nil, options = {})`

Parameters:
 - name: the attribute name
 - query: how to get data on cache miss. It will be set automatically if the name matches an association or an attribute.
 - options: see [here](#options)

### Access the cached attributes

"To avoid method name collision, all methods will be defined on the `Cacher` instead of `ActiveModel`. You can get the `cacher` from the class or from the instance (e.g. `User.cacher` or `user.cacher`), then access cached attributes via the method defined by `cache_at` (e.g. `user.cacher.the_attribute_name`)."

### Basic Example
```rb
class User < ActiveRecord::Base
  cache_at :something_you_want_to_cache, ->{ get_the_data_on_cache_miss }
end

user.cacher.something_you_want_to_cache
```


## Examples

### Example 1: Cache the number of active users
Specify the method name as `active_count`. After using lambda `User.active.count` to define how the data can be accessed when there is a cache miss, you can get the cached data by calling `active_count` method on the cacher `User.cacher`.

```rb
class User < ActiveRecord::Base
  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }
  cache_at :active_count, ->{ active.count }, expire_by: 'User#last_login_at'
end

@count = User.cacher.active_count
```

You may want to flush cache on the number of active users changed. It can be done by setting [`expire_by`](#expire_by). In this case, `User#last_login_at` means flushing the cache when a user's `last_login_at` is changed (by save, update, create, destroy or delete).

### Example 2: Cache the number of users

In this example, the cache should be cleaned on user `destroyed`, or new user `created`, but not on user `updated`. You can specify the cleaning callback to only fire on certain events by [`on`](#on).

```rb
class User < ActiveRecord::Base
  cache_at :count, ->{ count }, expire_by: 'User', on: [:create, :destroy]
end

@count = User.cacher.count
```

### Example 3: Access the cacher from a model instance

You could use the cacher from the instance scope, e.g. `user.cacher`, instead of `User.cacher`. The difference is that the `binding` of query lambda is changed. In this example, you can write the query as `posts.exists?` which is in instance scope. The binding of the lambda is `user`, not `User`, so that it accesses `posts` method of `user`.

```rb
class User < ActiveRecord::Base
  has_many :posts
  cache_at :has_post?, ->{ posts.exists? }, expire_by: :posts
end

do_something if current_user.cacher.has_post?
```

In this example, the cache should be cleaned when the `posts` of the user is changed. If you set `expire_by` to the association: `:posts`, it will do all the work for you (It actually sets [`expire_by`](#expire_by) to `Post#user_id` and [`foreign_key`](#foreign_key), which is needed for backtracing the user id from post, to `:user_id`). 


### Example 4: Pass an argument to the query lambda

You can also cache the result of outer service.`email_valid?` doesn't match an association or an attribute, so by default, the cache will not be cleaned by any changes.

```rb
class User < ActiveRecord::Base
  cache_at :email_valid?, ->(email){ ValidEmail2::Address.new(email).valid_mx? }
end

render_error if not User.cacher_at('pearl@example.com').email_valid?
```

The query lambda can have one parameter. You can pass variable to it by using `cacher_at`. For example, `User.cacher_at(email)`.

```rb
class User < ActiveRecord::Base
  cache_at :email_valid?, ->(email){ ValidEmail2::Address.new(email).valid_mx? }, primary_key: :email
end

render_error if not current_user.cacher.email_valid?
```

The query lambda can also be accessed from instance cacher, but you have to set [`primary_key`](#primary_key). The primary key specifies which attribute should be passed to the parameter.

### Example 5: Store all data in hash

Sometimes you may need to query multiple objects. Although the query results will be cached, the application still needs to query the cache server multiple times. If one communication takes 0.1 ms, 1000 communications will take 100ms! For example:

```rb
class Skill < ActiveRecord::Base
  cache_at :atk_power
end

# This will retrieve the data from cache servers multiple times.
@attack = skill_ids.inject(0){|sum, id| sum + Skill.cacher_at(id).atk_power }
```

One solution is to store a lookup table into the cache, so that only one cache object is stored. This will allow you to retrieve all of the needed data in one query.

```rb
class Skill < ActiveRecord::Base
  cache_at :atk_powers, ->{ pluck(:id, :atk_power).to_h }, expire_by: 'Skill#atk_power'
end

# This will retrieve the data from cache servers only 1 times.
@attack = skill_ids.inject(0){|sum, id| sum + Skill.cacher.atk_powers[id] }
```

### Example 6: Clean the cache manually

Sometimes it is necessary to maintain the cache manually (For example, after calling `update_all`, `delete_all` or `import` records without calling callbacks).

```rb
class User < ActiveRecord::Base
  has_one :profile
  cache_at :profile
end

# clean the cache by name
current_user.cacher.clean(:profile)

# or calling the clean_* method
current_user.cacher.clean_profile

# clean the cache without loading model
User.cacher_at(user_id).clean_profile
```

### Example 7: Peek the data stored in cache

If you only want to check the cached objects, but don't want it to load them from the database automatically when there is no cache, you can use `peek` method on `cacher`.

```rb
class User < ActiveRecord::Base
  has_one :profile
  cache_at :profile
end

# peek the cache by name
current_user.cacher.peek(:profile)

# or calling the peek_* method
current_user.cacher.peek_profile

# peek the cache without loading model
User.cacher_at(user_id).peek_profile
```


## Smart Caching

### Multi-level Cache
There is multi-level cache in order to increase the speed of data access.

1. RequestStore
2. Rails.cache
3. Association Cache
4. Database

`RequestStore` is used to make sure the same object will not be loaded from cache twice, since the data transfer between `Cache` and `Application` consumes time.

`Association Cache` prevents preloaded objects being loaded again.

For example:
```rb
user = User.includes(:posts).take
user.cacher.posts # => no query will be made even on cache miss.
```

## Convenient syntax sugar for caching ActiveRecord

### Caching Associations
```rb
class User < ActiveRecord::Base
  has_one :profile
  cache_at :profile
end

@profile = current_user.cacher.profile

# directly get profile without loading user.
@profile = User.cacher_at(user_id).profile
```

### Caching Self

Cache self by id:
```rb
class User < ActiveRecord::Base
  cache_self
end

@user = User.cacher.find_by(id: user_id)

# peek cache
User.cacher.peek_by(id: user_id)

# clean cache
User.cacher.clean_by(id: user_id)
```

Also support caching self by other columns:
```rb
class User < ActiveRecord::Base
  cache_self by: :account
end

@user = User.cacher.find_by(account: 'khiav')

# peek cache
User.cacher.peek_by(account: 'khiav')

# clean cache
User.cacher.clean_by(account: 'khiav')
```

### Caching Attributes

```rb
class Profile < ActiveRecord::Base
  cache_at :point
end

@point = Profile.cacher_at(profile_id).point
```

## Options

### :expire_by

Monitor on the specific model. Clean the cached objects if targets are changed.

  - If empty, e.g. `nil` or `''`: Monitoring nothing.

  - If string, e.g. `User`: Monitoring all attributes of `User`.

  - If string with keyword `#`, e.g. `User#last_login_in_at`: Monitoring only an specific attribute.

  - If symbol, e.g. `:posts`: Monitoring on the association. It will monitor all attributes of `Post` and set the `foreign_key'.

  - The default value depends on the `name`. If `name`:
  
  - Is an association, monitoring the association klass
  
  - Is an attribute, monitoring current klass and the attribute name
  
  - In other cases, monitoring nothing

### :on

 Fire changes only by a certain action with the `on` option. Like the same option of [after_commit](https://apidock.com/rails/ActiveRecord/Transactions/ClassMethods/after_commit).

  - if `:create`: Clean the cache only on new record is created, e.g. `Model.create`.

  - if `:update`: Clean the cache only on the record is updated, e.g. `model.update`.

  - if `:destroy`: Clean the cache only on the record id destroyed, e.g. `model.destroy`, `model.delete`.

  - if `array`, e.g. `[:create, :update]`: Clean the cache by any of specified actions.

  - Default value is `[:create, :update, :destroy]`

### :foreign_key

- Is needed only for caching assoication

- Does not need to be set if [`expire_by`](#expire_by) is set to monitor association.

- Is used for backtracing the cache key from cached objects. For example, it is used if `user` has_many `posts`, and `posts` is cached by user.id. If the post is changed, the column it is going to target must be specified so that the post can clean the cache at user (In this example mentioned, the column was `user_id`).

- Has the default value `:id`.

- Will be automatically determined if [`expire_by`](#expire_by) is symbol

### :primary_key

- Is needed to know which attribute should be passed to the parameter when using the instance `cacher`. For example, if a query, named `email_valid?`, uses `user.email` as parameter, and you call it from instance: `user.cacher.email_valid?`, pass `user.id` as the argument.

- Has the default value `:id`.

## Future works

- [ ] caching polymorphic associations
- [ ] non-unique secondary indexes
- [ ] caching attributes by multiple keys
- [ ] testing counter cache
- [ ] testing has_many through
- [ ] testing has_and_belongs_to_many

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb` before running `bundle exec rake release` (This command will create a git tag for the version, push the git commits, tags and the `.gem` files to rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/active_model_cachers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
