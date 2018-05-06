class User < ActiveRecord::Base
  has_many :posts
  has_many :post_without_caches, class_name: 'Post'
  has_one :profile, dependent: :delete
  has_one :contact, dependent: :delete

  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }

  cache_at :profile
  cache_at :contact

  cache_at :count, ->{ User.count }, expire_by: 'User', on: [:create, :destroy]
  cache_at :active_count, ->{ User.active.count }, expire_by: 'User#last_login_at'
  cache_at :has_post?, ->(id){ Post.where(user_id: id).exists? }, expire_by: 'Post#user_id', foreign_key: :user_id # TODO: posts.exists?
  cache_at :has_post_without_cache?, ->(id){ PostWithoutCache.where(user_id: id).exists? }, expire_by: 'PostWithoutCache#user_id', foreign_key: :user_id
end
