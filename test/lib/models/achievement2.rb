# frozen_string_literal: true

class Achievement2 < ActiveRecord::Base
  has_and_belongs_to_many :users, after_add: ->(_, user){ user.cacher.clean(:has_achievement2s?) },
                                  after_remove: ->(_, user){ user.cacher.clean(:has_achievement2s?) }
end
