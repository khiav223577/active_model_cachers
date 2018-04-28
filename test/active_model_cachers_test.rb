require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    
  end

  def test_cachers_will_cache
    profile = User.find_by(name: 'John1').profile
    assert_equal 10, Profile.point_cachers[profile.id].get
    assert_equal 10, User.profile_cachers[profile.id].get.point
  end
end
