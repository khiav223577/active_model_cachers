# frozen_string_literal: true

class UserAchievement < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
  belongs_to :achievements_by_belongs_to_many, class_name: 'Achievement'
end
