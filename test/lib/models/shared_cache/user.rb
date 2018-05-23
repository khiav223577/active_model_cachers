# frozen_string_literal: true
class SharedCache::User < ActiveRecord::Base
  has_one :profile, class_name: 'SharedCache::Profile'

  cache_at :profile
end
