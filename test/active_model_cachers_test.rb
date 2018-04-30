require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    Rails.cache.clear
    RequestStore.clear!
  end

  # ----------------------------------------------------------------
  # ● association cache
  # ----------------------------------------------------------------
  def test_has_one_cache
    profile = User.find_by(name: 'John1').profile
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)
  end

  def test_has_one_cache_when_update_nothing
    profile = User.find_by(name: 'John1').profile
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)

    profile.save
    assert_cache('cacher_key_of_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, cacher.get.point }
    assert_cache('cacher_key_of_Profile_1' => profile)
  end

  def test_has_one_cache_when_update
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

  def test_has_one_cache_when_destroy
    profile = Profile.create(point: 13)
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 13, cacher.get.point }
    assert_cache("cacher_key_of_Profile_#{profile.id}" => profile)

    profile.destroy
    assert_cache({})

    assert_queries(1){ assert_nil cacher.get }
    assert_cache({})
  ensure
    profile.destroy
  end

  def test_has_one_cache_when_destroyed_by_dependent_delete
    profile = Profile.create(point: 17)
    user = User.create(profile: profile)
    cacher = User.profile_cachers[profile.id]

    assert_queries(1){ assert_equal 17, cacher.get.point }
    assert_cache("cacher_key_of_Profile_#{profile.id}" => profile)

    user.destroy
    assert_cache({})

    assert_queries(1){ assert_nil cacher.get }
    assert_cache({})
  ensure
    user.destroy
  end

  # ----------------------------------------------------------------
  # ● attribute cache
  # ----------------------------------------------------------------
  def test_attribute_cache
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)

    assert_queries(0){ assert_equal 10, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)
  end

  def test_attribute_cache_when_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    profile.save
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    assert_queries(0){ assert_equal 30, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)
  end

  def test_attribute_cache_when_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    profile.update_attributes(point: 32)
    assert_cache({})

    assert_queries(1){ assert_equal 32, Profile.cacher(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 32)
  ensure
    profile.update_attributes(point: 30)
  end

  def test_attribute_cache_when_destroy
    profile = Profile.create(point: 30)

    assert_queries(1){ assert_equal 30, Profile.cacher(profile.id).point }  
    assert_cache("cacher_key_of_Profile_at_point_#{profile.id}" => 30)

    profile.destroy
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher(profile.id).point }
    assert_cache({})
  ensure
    profile.destroy
  end
end
