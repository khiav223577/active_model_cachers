# frozen_string_literal: true
class Profile < ActiveRecord::Base
  belongs_to :user

  cache_self
  cache_self by: :token
  cache_at :point
end
