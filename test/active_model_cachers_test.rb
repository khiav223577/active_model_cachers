require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    
  end

  def test_cachers_will_cache
    profile = User.find_by(name: 'John1').profile

    assert_equal({}, Rails.cache.all_data)
    assert_equal 10, Profile.point_cachers[profile.id].get

    def Profile.find_by(*args)
      fail 'should not be called'
    end

    assert_equal 10, Profile.point_cachers[profile.id].get
    assert_equal({'cacher_key_of_Profile_at_point_1' => 10}, Rails.cache.all_data)
  end
end
