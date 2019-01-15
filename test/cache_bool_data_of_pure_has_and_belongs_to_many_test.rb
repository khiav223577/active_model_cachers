# frozen_string_literal: true
require 'base_test'

class CacheBoolDataOfPureHasAndBelongsToManyTest < BaseTest
  def setup
    super
    # Cannot asscess private User::HABTM_Achievement2s directly in Rails 5
    @middle_klass = ActiveRecord::VERSION::MAJOR > 4 ? User.const_get(:HABTM_Achievement2s) : User::HABTM_Achievement2s
  end
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

    assert_queries(1){ @middle_klass.create(user_id: user.id, achievement2_id: achievement.id) }
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

  def test_create_by_assigning_reversely
    user = User.find_by(name: 'John4')
    achievement = Achievement2.create

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)

    assert_queries(2){ achievement.users = [user] }
    assert_cache({})

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)
  ensure
    achievement.destroy
  end

  def test_delete_by_assigning_empty
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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

  def test_delete_by_calling_clear
    # FIXME: it's is equivalent to #delete_all which will not fire any callback
    skip

    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(2){ user.achievement2s.clear }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    user.achievement2s = [] if user
  end

  def test_delete_by_assigning_others
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    other_achievement = Achievement2.last
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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
  def test_destroy_middle_association
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    user_achievement = @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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

  def test_destroy
    # FIXME:
    # It doesn't work for has_and_belongs_to_many association, since when you call achievement.destroy, it will call `user_achievements.delete_all`
    # to delete user_achievements which unfortunately will not fire any callback.
    # See: /.rvm/gems/ruby-2.3.3/gems/activerecord-4.2.11/lib/active_record/associations.rb
    # > def destroy_associations
    # >   association(:#{middle_reflection.name}).delete_all(:delete_all)
    # >   association(:#{name}).reset
    # >   super
    # > end
    #
    # May related to https://github.com/rails/rails/issues/14365
    skip

    user = User.find_by(name: 'John4')
    achievement = Achievement2.create
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

    assert_queries(1){ assert_equal true, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => true)

    assert_queries(2){ achievement.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal false, user.cacher.has_achievement2s? }
    assert_queries(0){ assert_equal false, user.cacher.has_achievement2s? }
    assert_cache('active_model_cachers_User_at_has_achievement2s?_4' => ActiveModelCachers::FalseObject)
  ensure
    achievement.delete if achievement
    user.achievement2s = [] if user
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete_middle_association
    user = User.find_by(name: 'John4')
    achievement = Achievement2.first
    user_achievement = @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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
    @middle_klass.create(user_id: user.id, achievement2_id: achievement.id)

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
