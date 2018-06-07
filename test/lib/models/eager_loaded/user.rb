# frozen_string_literal: true
class EagerLoaded::User < ActiveRecord::Base
  has_one :profile, class_name: 'EagerLoaded::Profile'

  cache_at :profile
end
