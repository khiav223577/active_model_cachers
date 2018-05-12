# frozen_string_literal: true
class User < ActiveRecord::Base
  has_many :posts
  has_many :posts_without_cache, class_name: 'PostWithoutCache'

  has_one :profile, dependent: :delete
  has_one :contact, dependent: :delete

  belongs_to :language
  belongs_to :language2

  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }

  cache_at :profile
  cache_at :contact
  cache_at :language
  cache_at :language2
  cache_at :posts

  cache_at :count, ->{ User.count }, expire_by: 'User', on: [:create, :destroy]
  cache_at :active_count, ->{ User.active.count }, expire_by: 'User#last_login_at'
  cache_at :has_post?, ->(id){ Post.where(user_id: id).exists? }, expire_by: 'Post#user_id', foreign_key: :user_id
  cache_at :has_post2?, ->(id){ posts.exists? }, expire_by: :posts
  cache_at :has_post_without_cache?, ->(id){ PostWithoutCache.where(user_id: id).exists? }, expire_by: 'PostWithoutCache#user_id', foreign_key: :user_id
  cache_at :has_post_without_cache2?, ->(id){ posts_without_cache.exists? }, expire_by: 'PostWithoutCache#user_id', foreign_key: :user_id
end
