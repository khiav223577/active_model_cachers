# frozen_string_literal: true
class User < ActiveRecord::Base
  has_many :posts
  has_many :posts_without_cache, class_name: 'PostWithoutCache'

  has_one :profile, dependent: :delete
  has_one :contact, dependent: :delete

  belongs_to :language
  belongs_to :language2

  has_many :user_achievements
  has_many :achievements, through: :user_achievements
  has_and_belongs_to_many :achievements_by_belongs_to_many, class_name: 'Achievement', join_table: :user_achievements
  has_and_belongs_to_many :achievement2s

  scope :active, ->{ where('last_login_at > ?', 7.days.ago) }

  cache_at :profile
  cache_at :contact
  cache_at :language
  cache_at :language2
  cache_at :posts

  cache_at :count, ->{ count }, expire_by: 'User', on: [:create, :destroy]
  cache_at :active_count, ->{ active.count }, expire_by: 'User#last_login_at'

  cache_at :has_post?, ->(id){ Post.where(user_id: id).exists? }, expire_by: 'Post#user_id', foreign_key: :user_id
  cache_at :has_post2?, ->{ posts.exists? }, expire_by: :posts
  cache_at :has_post_without_cache?, ->(id){ PostWithoutCache.where(user_id: id).exists? }, expire_by: 'PostWithoutCache#user_id', foreign_key: :user_id
  cache_at :has_post_without_cache2?, ->(id){ posts_without_cache.exists? }, expire_by: 'PostWithoutCache#user_id', foreign_key: :user_id

  cache_at :has_achievements?, ->(_){ achievements.exists? }, expire_by: :achievements
  cache_at :has_achievement2s?, ->(_){ achievement2s.exists? }, expire_by: :achievement2s
  cache_at :has_achievements_by_belongs_to_many?, ->(_){ achievements_by_belongs_to_many.exists? }, expire_by: :achievements_by_belongs_to_many

  cache_at :email_valid?, ->(email){ ValidEmail2::Address.new(email).valid_mx? }, primary_key: :email
end
