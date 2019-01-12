# frozen_string_literal: true
require 'base_test'

class CacheBoolDataOfHasManyThroughTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_1' => true)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John4')
    achievement = Achievement.take

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ UserAchievement.create(user: user, achievement: achievement) }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    user.user_achievements.delete_all
  end

  def test_create_by_pushing
    user = User.find_by(name: 'John4')
    achievement = Achievement.take

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ user.achievements << achievement }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    user.user_achievements.delete_all
  end
end
