# frozen_string_literal: true
class EagerLoaded::Language < ActiveRecord::Base
  has_many :users, class_name: 'EagerLoaded::User'
end
