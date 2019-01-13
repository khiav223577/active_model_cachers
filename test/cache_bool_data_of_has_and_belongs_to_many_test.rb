# frozen_string_literal: true
require 'base_test'

class CacheBoolDataOfHasAndBelongsToManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_1' => true)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John4')
    achievement = Achievement.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ UserAchievement.create(user: user, achievement: achievement) }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => true)
  ensure
    user.user_achievements.delete_all
  end

  def test_create_by_pushing
    user = User.find_by(name: 'John4')
    achievement = Achievement.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ user.achievements_by_belongs_to_many << achievement }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => true)
  ensure
    user.user_achievements.delete_all
  end

  def test_assign_empty
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => true)

    assert_queries(2){ user.achievements_by_belongs_to_many = [] }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => ActiveModelCachers::FalseObject)
  ensure
    user_achievement.delete
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => true)

    assert_queries(1){ user_achievement.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => ActiveModelCachers::FalseObject)
  ensure
    user_achievement.delete
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_destroy
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => true)

    assert_queries(1){ user_achievement.delete }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_4' => ActiveModelCachers::FalseObject)
  ensure
    user_achievement.delete
  end
end
