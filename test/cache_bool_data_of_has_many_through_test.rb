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
    achievement = Achievement.first

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
    achievement = Achievement.first

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

  def test_create_by_pushing_reversely
    user = User.find_by(name: 'John4')
    achievement = Achievement.create

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ achievement.users << user }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    achievement.destroy
    user.user_achievements.delete_all
  end

  def test_create_by_assigning
    user = User.find_by(name: 'John4')
    achievement = Achievement.first

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)

    assert_queries(2){ user.achievements = [achievement] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    user.user_achievements.delete_all
  end

  def test_create_by_assigning_reversely
    user = User.find_by(name: 'John4')
    achievement = Achievement.create

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)

    assert_queries(2){ achievement.users = [user] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    achievement.destroy
  end

  def test_delete_by_assigning_empty
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(2){ user.achievements = [] }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.user_achievements.delete_all
  end

  def test_delete_by_calling_clear
    # FIXME: it's is equivalent to #delete_all which will not fire any callback
    skip

    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(2){ user.achievements.clear }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.user_achievements.delete_all if user
  end

  def test_delete_by_assigning_others
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    other_achievement = Achievement.last
    UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(3){ user.achievements = [other_achievement] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)
  ensure
    user.user_achievements.delete_all
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy_middle_association
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(1){ user_achievement.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user_achievement.delete
  end

  def test_destroy
    user = User.find_by(name: 'John4')
    achievement = Achievement.create
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    # 2 queries from user_achievements.destroy_all calling by `has_many :user_achievements, dependent: :destroy`
    # 1 query from user_achievements.delete_all calling by `has_and_belongs_to_many :users_by_belongs_to_many`
    # 1 query from achievement.destroy
    assert_queries(4){ achievement.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    achievement.delete
    user_achievement.delete
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete_middle_association
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    user_achievement = UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(1){ user_achievement.delete }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user_achievement.delete
  end

  def test_delete_from_collection
    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(1){ user.achievements.delete(achievement) }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.user_achievements.delete_all
  end

  def test_delete_from_collection_with_only_id
    skip if ActiveRecord::VERSION::MAJOR < 4 # Rails 3's #delete method can only receive model

    user = User.find_by(name: 'John4')
    achievement = Achievement.first
    UserAchievement.create(user: user, achievement: achievement)

    assert_queries(1){ assert_equal true, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => true)

    assert_queries(2){ user.achievements.delete(achievement.id) }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievements? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievements? }
    assert_cache('active_model_cachers_User_at_has_achievements?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.user_achievements.delete_all if user
  end
end
