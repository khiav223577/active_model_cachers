require 'base_test'

class CacheSelfTest < BaseTest
  def test_cache_self
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('cacher_key_of_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('cacher_key_of_Profile_1' => profile)
  end
end
