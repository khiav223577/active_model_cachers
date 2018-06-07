# frozen_string_literal: true
class EagerLoaded::User < ActiveRecord::Base
  has_one :profile, class_name: 'EagerLoaded::Profile'
  belongs_to :language, class_name: 'EagerLoaded::Language'

  cache_at :profile
  cache_at :language
end
