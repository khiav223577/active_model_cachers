require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    Rails.cache.clear
    RequestStore.clear!
  end

  # ----------------------------------------------------------------
  # ● association cache
  # ----------------------------------------------------------------
  def test_cache_profile
    profile = User.find_by(name: 'John1').profile
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)
  end

  def test_cache_profile_after_update
    profile = User.find_by(name: 'John1').profile
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)

    profile.update_attributes(point: 12)
    assert_cache({})

    assert_queries(1){ assert_equal 12, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)
  ensure 
    profile.update_attributes(point: 10)
  end

  # ----------------------------------------------------------------
  # ● attribute cache
  # ----------------------------------------------------------------
  def test_cache_profile_attribute
    profile = User.find_by(name: 'John1').profile
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1){ assert_equal 10, cacher.get }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)

    assert_queries(0){ assert_equal 10, cacher.get }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)
  end

  def test_clean_profile_attribute_cache_after_update
    profile = User.find_by(name: 'John2').profile
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1){ assert_equal 30, cacher.get }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    profile.update_attributes(point: 32)
    assert_cache({})

    assert_queries(1){ assert_equal 32, cacher.get }
    assert_cache('cacher_key_of_Profile_at_point_2' => 32)
  ensure
    profile.update_attributes(point: 30)
  end

  def test_clean_profile_attribute_cache_after_destroy
    profile = Profile.create(point: 30)
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1){ assert_equal 30, cacher.get }  
    assert_cache("cacher_key_of_Profile_at_point_#{profile.id}" => 30)

    profile.destroy
    assert_cache({})

    assert_queries(1){ assert_nil cacher.get }
    assert_cache({})
  end
end
