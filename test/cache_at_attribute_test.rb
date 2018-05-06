# frozen_string_literal: true
require 'base_test'

class CacheAtAttributeTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_1' => 10)
  end

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

  def test_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(0){ profile.save }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)
  end

  def test_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 30)

    assert_queries(1){ profile.update_attributes(point: 32) }
    assert_cache({})

    assert_queries(1){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_cache('active_model_cachers_Profile_at_point_2' => 32)
  ensure
    profile.update_attributes(point: 30)
  end

  def test_destroy
    profile = Profile.create(point: 30)

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 30)

    assert_queries(1){ profile.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  def test_delete
    profile = Profile.create(point: 30)

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => 30)

    assert_queries(1){ profile.delete }
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

    assert_queries(3){ user.destroy } # 1. delete user. 2: delete profile by dependent. 3: delete contact by dependent.
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_queries(0){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache("active_model_cachers_Profile_at_point_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    user.destroy
  end
end
