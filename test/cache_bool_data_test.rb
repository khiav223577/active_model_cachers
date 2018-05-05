require 'base_test'

class CacheBoolDataTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_1' => true)
  end

  def test_false_data_should_be_cached
    user = User.find_by(name: 'John4')

    # false data should be cached, no more query is called if it is cached.
    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_4' => ActiveModelCachers::FalseObject)
  end
end
