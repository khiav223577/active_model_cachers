# frozen_string_literal: true
class PostWithoutCache < ActiveRecord::Base
  belongs_to :user
end
