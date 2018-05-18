# frozen_string_literal: true
require 'base_test'

class CacheAllSkillsPowerTest < BaseTest
  def test_basic_usage
    assert_queries(1){ assert_equal 40, Skill.cacher.atk_powers[2] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    skill = nil

    assert_queries(1){ assert_equal 40, Skill.cacher.atk_powers[2] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})

    assert_queries(1){ skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90) }
    assert_cache({})

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})
  ensure
    skill.delete if skill
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    Rails.cache.write('active_model_cachers_Skill_at_atk_powers', 1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70)
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})

    assert_queries(0){ Skill.cacher.clean(:atk_powers) }
    assert_cache({})
  end

  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90)

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(0){ skill.save }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(0){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})
  ensure
    skill.delete if skill
  end

  def test_update_unrelated_column
    skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90)

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(1){ skill.update_attributes(name: 'Crystal Blast') }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(0){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})
  ensure
    skill.delete if skill
  end

  def test_update
    skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90)

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(1){ skill.update_attributes(atk_power: 77) }
    assert_cache({})

    assert_queries(1){ assert_equal 77, Skill.cacher.atk_powers[-1] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 77})
  ensure
    skill.delete if skill
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90)

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(1){ skill.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_nil Skill.cacher.atk_powers[-1] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})
  ensure
    skill.delete if skill
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    skill = Skill.create(id: -1, name: 'Crystal Shard', atk_power: 90)

    assert_queries(1){ assert_equal 90, Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_equal 80, Skill.cacher.atk_powers[3] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70, -1 => 90})

    assert_queries(1){ skill.delete }
    assert_cache({})

    assert_queries(1){ assert_nil Skill.cacher.atk_powers[-1] }
    assert_queries(0){ assert_nil Skill.cacher.atk_powers[-1] }
    assert_cache('active_model_cachers_Skill_at_atk_powers' => {1 => 120, 2 => 40, 3 => 80, 4 => 60, 5 => 75, 6 => 70})
  ensure
    skill.delete if skill
  end
end
