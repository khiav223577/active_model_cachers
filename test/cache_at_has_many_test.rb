# frozen_string_literal: true
require 'base_test'

class CacheAtHasManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_queries(0){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_cache('active_model_cachers_User_at_posts_1' => 3)
  end
end
