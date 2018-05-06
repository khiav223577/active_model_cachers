require 'active_model_cachers'
require 'lib/models/active_base.rb'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.text :serialized_attribute
    t.datetime :last_login_at
  end

  create_table :posts, :force => true do |t|
    t.integer :user_id
    t.string :title
  end

  create_table :post_without_caches, :force => true do |t|
    t.integer :user_id
    t.string :title
  end

  create_table :profiles, :force => true do |t|
    t.integer :user_id
    t.integer :point
  end

  create_table :contacts, :force => true do |t|
    t.integer :user_id
    t.string :phone
  end

  create_table :difficulties, :force => true do |t|
    t.integer :level
    t.string :description
  end
end

ActiveSupport::Dependencies.autoload_paths << File.expand_path('../models/', __FILE__)

users = User.create([
  {
    :name          => 'John1',
    :email         => 'john1@example.com',
    :profile       => Profile.create(point: 10),
    :contact       => Contact.create(phone: '12345'),
    :last_login_at => Time.now,
  }, {
    :name          => 'John2',
    :email         => 'john2@example.com',
    :profile       => Profile.create(point: 30),
    :last_login_at => Time.now,
  }, {
    :name          => 'John3',
    :email         => 'john3@example.com',
    :profile       => Profile.create(point: 50),
    :last_login_at => 1.month.ago,
  }, {
    :name          => 'John4',
    :email         => 'john4@example.com',
    :profile       => Profile.create(point: 70),
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
