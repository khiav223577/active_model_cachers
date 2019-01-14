# frozen_string_literal: true
require 'base_test'

class CacheBoolDataOfPureHasAndBelongsToManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_1' => true)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id) }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)
  ensure
    user.achievement2s = []
  end

  def test_create_by_pushing
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ user.achievement2s << achievement }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)
  ensure
    user.achievement2s = []
  end

  def test_create_by_assigning
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)

    assert_queries(2){ user.achievement2s = [achievement] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)
  ensure
    user.achievement2s = []
  end

  def test_delete_by_assigning_empty
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(2){ user.achievement2s = [] }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = []
  end

  def test_delete_by_assigning_others
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    other_achievement = Achievement2.last
    User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(3){ user.achievement2s = [other_achievement] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)
  ensure
    user.achievement2s = []
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    user_achievement = User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(1){ user_achievement.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = []
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    user_achievement = User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(1){ user_achievement.delete }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = []
  end

  def test_delete_from_collection
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(1){ user.achievement2s.delete(achievement) }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = []
  end

  def test_delete_from_collection_with_only_id
    skip if ActiveRecord::VERSION::MAJOR < 4 # Rails 3's #delete method can only receive model

    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    User::HABTM_Achievement2s.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(2){ user.achievement2s.delete(achievement.id) }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = [] if user
  end
end
