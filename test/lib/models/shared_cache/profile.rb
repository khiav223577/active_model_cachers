# frozen_string_literal: true
class SharedCache::Profile < ActiveRecord::Base
  belongs_to :user, class_name: 'SharedCache::User'

  cache_self by: :user_id
end
