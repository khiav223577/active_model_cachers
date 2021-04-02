# frozen_string_literal: true
require 'base_test'

class CacheAtAttributeTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)
  end

  def test_basic_usage_of_instance_cacher
    profile = Profile.select(:id).first # The only use case of this may be that profile doesn't select the attribute.

    assert_queries(1){ assert_equal 10, profile.cacher.point }
    assert_queries(0){ assert_equal 10, profile.cacher.point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)
  end

  def test_instance_cacher_without_association_cache
    profile1 = Profile.select(:id).first # The only use case of this may be that profile doesn't select the attribute.
    profile2 = Profile.select(:id).first # The only use case of this may be that profile doesn't select the attribute.

    assert_queries(1){ assert_equal 10, profile1.cacher.point }
    assert_queries(0){ assert_equal 10, profile2.cacher.point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)
  end

  def test_instance_cacher_to_use_loaded_associations
    profile = Profile.first

    assert_queries(0){ assert_equal 10, profile.cacher.point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    profile = nil

    assert_queries(1){ assert_nil Profile.cacher_at(-1).point }
    assert_queries(0){ assert_nil Profile.cacher_at(-1).point }
    assert_cache('active_model_cachers_Profile_at_point_-1' => ActiveModelCachers::NilObject)

    assert_queries(1){ profile = Profile.create(id: -1, point: 3) }
    assert_cache({})

    assert_queries(1){ assert_equal 3, Profile.cacher_at(-1).point }
    assert_queries(0){ assert_equal 3, Profile.cacher_at(-1).point }
    assert_cache('active_model_cachers_Profile_at_point_-1' => 3)
  ensure
    profile.destroy if profile
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_at_point_1', 10)
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)

    assert_queries(0){ Profile.cacher_at(profile.id).clean_point }
    assert_cache({})
  end

  def test_clean2
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_at_point_1', 10)
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)

    assert_queries(0){ Profile.cacher_at(profile.id).clean(:point) }
    assert_cache({})
  end

  def test_clean_in_instance_cacher
    profile = Profile.select(:id).first

    Rails.cache.write('active_model_cachers_Profile_at_point_1', 10)
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)

    assert_queries(0){ profile.cacher.clean_point }
    assert_cache({})
  end

  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    profile = User.find_by(name: 'John3').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(0){ profile.save }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)
  end

  def test_update
    profile = User.find_by(name: 'John3').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(1){ profile.update(point: 32) }
    assert_cache({})

    assert_queries(1){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 32)
  ensure
    profile.update(point: 30)
  end

  def test_update_birthday
    user = User.find_by(name: 'John1')

    assert_equal 10, user.cacher.age
    assert_cache('active_model_cachers_User_at_age_1' => 10)

    user.update(birthday: 10.years.ago + 3.days)
    assert_cache({})

    assert_equal 9, user.cacher.age
    assert_cache('active_model_cachers_User_at_age_1' => 9)
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    profile = Profile.create(point: 32)

    assert_queries(1){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 32)

    assert_queries(1){ profile.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    profile = Profile.create(point: 37)

    assert_queries(1){ assert_equal 37, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 37, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 37)

    assert_queries(1){ profile.delete }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.delete
  end

  def test_delete_without_model
    profile = Profile.create(id: -2, point: 41)

    assert_queries(1){ assert_equal 41, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 41, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 41)

    # 1: select profile.user_id to clean cache on user.profile, and select profile.token to clean cache on profile by token.
    # 2: delete profile.
    assert_queries(2){ Profile.delete(-2) }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.delete
  end

  def test_destroyed_by_dependent_delete
    profile = Profile.create(point: 17)
    user = User.create(profile: profile)

    assert_queries(1){ assert_equal 17, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 17, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 17)

    assert_queries(user_destroy_dependents_count){ user.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    user.destroy
  end
end
