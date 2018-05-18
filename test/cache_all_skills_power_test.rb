# frozen_string_literal: true
require 'base_test'

class CacheAllSkillsPowerTest < BaseTest
  def test_basic_usage
    assert_queries(1){ assert_equal 40, Skill.cacher.atk_powers[2] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})
  end
end
