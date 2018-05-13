# frozen_string_literal: true
require 'base_test'

class CacheSelfTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    profile = nil

    assert_queries(1){ assert_nil Profile.cacher_at(-1).self }
    assert_queries(0){ assert_nil Profile.cacher_at(-1).self }
    assert_cache('active_model_cachers_Profile_-1' => ActiveModelCachers::NilObject)

    assert_queries(1){ profile = Profile.create(id: -1, point: 3) }
    assert_cache({})

    assert_queries(1){ assert_equal 3, Profile.cacher_at(-1).self.point }
    assert_queries(0){ assert_equal 3, Profile.cacher_at(-1).self.point }
    assert_cache('active_model_cachers_Profile_-1' => profile)
  ensure
    profile.destroy if profile
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ Profile.cacher_at(profile.id).clean_self }
    assert_cache({})
  end

  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ profile.save }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(1){ profile.update_attributes(point: 12) }
    assert_cache({})

    assert_queries(1){ assert_equal 12, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 12, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  ensure
    profile.update_attributes(point: 10)
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 13, Profile.cacher_at(profile.id).self.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    assert_queries(1){ profile.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(0){ assert_nil User.cacher_at(profile.id).profile }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 13, Profile.cacher_at(profile.id).self.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    assert_queries(1){ profile.delete }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).self }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).self }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.delete
  end

  def test_destroyed_by_dependent_delete
    profile = Profile.create(point: 17)
    user = User.create(profile: profile)

    assert_queries(1){ assert_equal 17, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 17, Profile.cacher_at(profile.id).self.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    user.destroy
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).self }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).self }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    user.destroy
  end

  def test_delete_target_which_doesnt_cached_by_other_models
    difficulty = Difficulty.create(level: 4, description: 'vary hard')

    # make sure Difficulty only have cache_self, and doesn't cache by other models by something like cache_at :difficulty
    assert_equal [:self], Difficulty.cacher.class.attributes
    assert_equal 1, Difficulty.before_delete_hooks.size

    assert_queries(1){ assert_equal 4, Difficulty.cacher_at(difficulty.id).self.level }
    assert_queries(0){ assert_equal 4, Difficulty.cacher_at(difficulty.id).self.level }
    assert_cache("active_model_cachers_Difficulty_#{difficulty.id}" => difficulty)

    difficulty.delete
    assert_cache({})

    assert_queries(1){ assert_nil Difficulty.cacher_at(difficulty.id).self }
    assert_queries(0){ assert_nil Difficulty.cacher_at(difficulty.id).self }
    assert_cache("active_model_cachers_Difficulty_#{difficulty.id}" => ActiveModelCachers::NilObject)
  ensure
    difficulty.delete
  end

  def test_delete_should_not_clean_all_models_with_same_id
    profile = Profile.create(id: -1, point: 7)
    difficulty = Difficulty.create(id: -1, level: 4, description: 'vary hard')

    assert_queries(1){ assert_equal 7, Profile.cacher_at(profile.id).self.point }
    assert_queries(0){ assert_equal 7, Profile.cacher_at(profile.id).self.point }
    assert_queries(1){ assert_equal 4, Difficulty.cacher_at(difficulty.id).self.level }
    assert_queries(0){ assert_equal 4, Difficulty.cacher_at(difficulty.id).self.level }
    assert_cache('active_model_cachers_Profile_-1' => profile, 'active_model_cachers_Difficulty_-1' => difficulty)

    # delete difficulty with id = -1 should not clean the cache of profile with same id.
    difficulty.delete
    assert_cache('active_model_cachers_Profile_-1' => profile)

    assert_queries(0){ assert_equal 7, Profile.cacher_at(profile.id).self.point }
    assert_queries(1){ assert_nil Difficulty.cacher_at(difficulty.id).self }
    assert_queries(0){ assert_nil Difficulty.cacher_at(difficulty.id).self }
    assert_cache('active_model_cachers_Profile_-1' => profile, 'active_model_cachers_Difficulty_-1' => ActiveModelCachers::NilObject)
  ensure
    profile.delete
    difficulty.delete
  end
end
