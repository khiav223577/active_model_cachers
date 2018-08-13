# frozen_string_literal: true
require 'base_test'

class CacheAtHasAndBelongsToManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(3){ assert_equal [], user.cacher.roles.map(&:name) }
    assert_queries(0){ assert_equal [], user.cacher.roles.map(&:name) }
    assert_cache('active_model_cachers_User_at_posts_1' => user.roles.to_a)
  end
end
