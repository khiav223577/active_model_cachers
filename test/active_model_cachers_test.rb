require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    Rails.cache.clear
    $profile_call_count = 0
    def Profile.find_by(*args)
      $profile_call_count += 1
      super
    end
  end

  def test_cache_profile
    profile = User.find_by(name: 'John1').profile

    assert_equal({}, Rails.cache.all_data)
    assert_equal 10, User.profile_cachers[profile.id].get.point
    assert_equal 10, User.profile_cachers[profile.id].get.point
    assert_equal 1, $profile_call_count
    assert_equal({'cacher_key_of_User_at_profile_1' => profile}, Rails.cache.all_data)
  end


  def test_cache_profile_attribute
    profile = User.find_by(name: 'John1').profile

    assert_equal({}, Rails.cache.all_data)
    assert_equal 10, Profile.point_cachers[profile.id].get
    assert_equal 10, Profile.point_cachers[profile.id].get
    assert_equal 1, $profile_call_count
    assert_equal({'cacher_key_of_Profile_at_point_1' => 10}, Rails.cache.all_data)
  end
end
