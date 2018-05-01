require 'base_test'

class CacheAtAttributeTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_1' => 10)
  end

  def test_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    profile.save
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    assert_queries(0){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)
  end

  def test_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 30)

    profile.update_attributes(point: 32)
    assert_cache({})

    assert_queries(1){ assert_equal 32, Profile.cacher_at(profile.id).point }
    assert_cache('cacher_key_of_Profile_at_point_2' => 32)
  ensure
    profile.update_attributes(point: 30)
  end

  def test_destroy
    profile = Profile.create(point: 30)

    assert_queries(1){ assert_equal 30, Profile.cacher_at(profile.id).point }
    assert_cache("cacher_key_of_Profile_at_point_#{profile.id}" => 30)

    profile.destroy
    assert_cache({})

    assert_queries(1){ assert_nil Profile.cacher_at(profile.id).point }
    assert_cache({})
  ensure
    profile.destroy
  end
end
