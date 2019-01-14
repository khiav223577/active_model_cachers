# frozen_string_literal: true

class Achievement2 < ActiveRecord::Base
  has_and_belongs_to_many :users
end
