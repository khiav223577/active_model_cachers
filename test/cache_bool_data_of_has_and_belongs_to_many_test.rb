# frozen_string_literal: true
require 'base_test'

class CacheBoolDataOfHasAndBelongsToManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_queries(0){ assert_equal true, user.cacher.has_achievements_by_belongs_to_many? }
    assert_cache('active_model_cachers_User_at_has_achievements_by_belongs_to_many?_1' => true)
  end
end
