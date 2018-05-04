class User < ActiveRecord::Base
  has_many :posts
  has_one :profile, dependent: :delete
  has_one :contact, dependent: :delete

  cache_at :profile
  cache_at :contact
  cache_at :count, ->{ User.count }, expire_by: User
end
