# frozen_string_literal: true
require 'base_test'

class SharedCacheTest < BaseTest
  def test_update
    user = SharedCache::User.first

    assert_queries(1){ assert_equal 19, user.cacher.profile.point }
    assert_queries(0){ assert_equal 19, user.cacher.profile.point }
    assert_cache('active_model_cachers_SharedCache::Profile_by_user_id_1' => user.profile)

    assert_cache_queries(2) do # Delete cache at self and at self_by_user_id
      assert_queries(1){ user.profile.update_attributes(point: 12) }
    end
    assert_cache({})

    user = SharedCache::User.first
    assert_queries(1){ assert_equal 12, user.cacher.profile.point }
    assert_queries(0){ assert_equal 12, user.cacher.profile.point }
    assert_cache('active_model_cachers_SharedCache::Profile_by_user_id_1' => user.profile)
  ensure
    user.profile.update_attributes(point: 19)
  end
end
