require 'base_test'

class CacheSelfTest < BaseTest
  def test_basic_usage

    assert_queries(1){ assert_equal 4, User.cacher_at(nil).count }
    assert_cache('active_model_cachers_User_at_count' => 4)

    assert_queries(0){ assert_equal 4, User.cacher_at(nil).count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  end
end
