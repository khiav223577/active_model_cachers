# frozen_string_literal: true
class Post < ActiveRecord::Base
  belongs_to :user

  cache_self
end
