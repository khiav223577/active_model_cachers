# frozen_string_literal: true
class Skill < ActiveRecord::Base
  cache_at :atk_powers, ->{ Skill.pluck(:id, :atk_power).to_h }, expire_by: 'Skill#atk_power'
end
