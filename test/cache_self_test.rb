require 'base_test'

class CacheSelfTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, Profile.cacher_at(profile.id).self.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_create
    profile = nil

    assert_queries(1){ assert_nil Profile.cacher_at(-1).self }
    assert_queries(1){ assert_nil Profile.cacher_at(-1).self } # FIXME: should be 0 query
    assert_cache({})

    profile = Profile.create(id: -1, point: 3)
    assert_cache({})

    assert_queries(1){ assert_equal 3, Profile.cacher_at(-1).self.point }
    assert_queries(0){ assert_equal 3, Profile.cacher_at(-1).self.point }
    assert_cache('active_model_cachers_Profile_-1' => profile)
  ensure
    profile.destroy if profile
  end
end
