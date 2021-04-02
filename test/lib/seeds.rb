# frozen_string_literal: true
require 'active_model_cachers'
require 'lib/models/active_base.rb'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.integer :language_id
    t.integer :language2_id
    t.text :serialized_attribute
    t.datetime :last_login_at
    t.date :birthday
  end

  create_table :posts, :force => true do |t|
    t.integer :user_id
    t.string :title
  end

  create_table :languages, :force => true do |t|
    t.string :name
  end

  create_table :language2s, :force => true do |t|
    t.string :name
  end

  create_table :post_without_caches, :force => true do |t|
    t.integer :user_id
    t.string :title
  end

  create_table :profiles, :force => true do |t|
    t.integer :user_id
    t.integer :point
    t.string :token
  end

  create_table :contacts, :force => true do |t|
    t.integer :user_id
    t.string :phone
  end

  create_table :difficulties, :force => true do |t|
    t.integer :level
    t.string :description
    t.datetime :updated_at
  end

  create_table :skills, :force => true do |t|
    t.string :name
    t.integer :atk_power
  end

  create_table :shared_cache_users, :force => true do |t|
    t.string :name
  end

  create_table :shared_cache_profiles, :force => true do |t|
    t.integer :user_id
    t.integer :point
  end

  create_table :eager_loaded_languages, :force => true do |t|
    t.string :name
  end

  create_table :eager_loaded_users, :force => true do |t|
    t.string :name
    t.integer :language_id
  end

  create_table :eager_loaded_profiles, :force => true do |t|
    t.integer :user_id
    t.integer :point
  end

  create_table :user_achievements, force: true do |t|
    t.references :user, index: true
    t.references :achievement, index: true
  end

  create_table :achievements, force: true do |t|
    t.string :name
  end

  create_table :achievement2s_users, force: true do |t|
    t.references :user, index: true
    t.references :achievement2, index: true
  end

  create_table :achievement2s, force: true do |t| # use pure has_and_belongs_to_many without middle table model and specifying class_name
    t.string :name
  end
end

ActiveSupport::Dependencies.autoload_paths << File.expand_path('../models/', __FILE__)
ActiveSupport::Dependencies.autoload_paths << File.expand_path('../services/', __FILE__)

# make sure `Profile.cache_self` be executed first, then `User.cache_at :profile`
require_relative 'models/eager_loaded/profile.rb'
require_relative 'models/eager_loaded/user.rb'
# require_relative 'models/eager_loaded/language.rb' # EagerLoaded::Language is auto-loaded in models/eager_loaded/user.rb
fail 'language should be defined here' if not defined?(EagerLoaded::Language)

languages = Language.create([
  {name: 'en'},
  {name: 'zh-tw'},
  {name: 'jp'},
])

Skill.create([
  {
    :name      => 'Heavy Strike',
    :atk_power => 120,
  },
  {
    :name      => 'Fire Trap',
    :atk_power => 40,
  },
  {
    :name      => 'Sweep',
    :atk_power => 80,
  },
  {
    :name      => 'Frost Bomb',
    :atk_power => 60,
  },
  {
    :name      => 'Earthquake',
    :atk_power => 75,
  },
  {
    :name      => 'Dark Shock',
    :atk_power => 70,
  },
])

users = User.create([
  {
    :name          => 'John1',
    :email         => 'john1@example.com',
    :contact       => Contact.create(phone: '12345'),
    :language      => languages[1],
    :last_login_at => Time.now,
    :birthday      => 10.year.ago - 3.days,
  }, {
    :name          => 'John2',
    :email         => 'john2@example.com',
    :profile       => Profile.create(point: 10, token: 'tt9wav'),
    :language      => languages[1],
    :last_login_at => Time.now,
  }, {
    :name          => 'John3',
    :email         => 'john3@example.com',
    :profile       => Profile.create(point: 30, token: 'mhfbfn'),
    :language      => languages[0],
    :last_login_at => 1.month.ago,
  }, {
    :name          => 'John4',
    :email         => 'john4@example.com',
    :profile       => Profile.create(point: 50, token: 'j0pbel'),
  },
])

Post.create([
  {:title => "John1's post1", :user_id => users[0].id},
  {:title => "John1's post2", :user_id => users[0].id},
  {:title => "John1's post3", :user_id => users[0].id},
  {:title => "John2's post1", :user_id => users[1].id},
  {:title => "John2's post2", :user_id => users[1].id},
  {:title => "John3's post1", :user_id => users[2].id},
])

Difficulty.create([
  {:level => 1, :description => 'easy'},
  {:level => 2, :description => 'normal'},
  {:level => 3, :description => 'hard'},
])

shared_cache_users = SharedCache::User.create([
  {name: 'Pearl'},
  {name: 'Khiav'},
])

SharedCache::Profile.create([
  {user_id: shared_cache_users[0].id, point: 19},
])

eager_loaded_languages = EagerLoaded::Language.create([
  {name: 'en'},
  {name: 'zh-tw'},
  {name: 'jp'},
])

eager_loaded_users = EagerLoaded::User.create([
  {:name => 'Pearl', :language => eager_loaded_languages[1]},
  {:name => 'Khiav', :language => eager_loaded_languages[2]},
])

EagerLoaded::Profile.create([
  {user_id: eager_loaded_users[0].id, point: 19},
])

achievements = Achievement.create([
  { name: 'achievement1' },
  { name: 'achievement2' },
  { name: 'achievement3' },
])

achievement2s = Achievement2.create([
  { name: 'achievement1' },
  { name: 'achievement2' },
  { name: 'achievement3' },
])

users[0].achievements = [achievements[0]]
users[1].achievements = [achievements[0], achievements[2]]

users[0].achievement2s = [achievement2s[0]]
users[1].achievement2s = [achievement2s[0], achievement2s[2]]

