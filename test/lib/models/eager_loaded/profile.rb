# frozen_string_literal: true
class EagerLoaded::Profile < ActiveRecord::Base
  belongs_to :user, class_name: 'EagerLoaded::User'

  cache_self
  cache_self by: :user_id
end
