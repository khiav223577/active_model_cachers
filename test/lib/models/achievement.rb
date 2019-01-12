# frozen_string_literal: true

class Achievement < ActiveRecord::Base
  has_many :user_achievements
  has_many :users, through: :user_achievements
  has_and_belongs_to_many :users_by_belongs_to_many, class_name: 'User', join_table: :user_achievements
end
