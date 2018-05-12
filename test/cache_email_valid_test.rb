# frozen_string_literal: true
require 'base_test'

class CacheEmailValidTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John2')
    assert_queries(1){ assert_equal true, User.cacher_at('john2@example.com').email_valid? }
    assert_queries(0){ assert_equal true, User.cacher_at('john2@example.com').email_valid? }
    assert_cache('active_model_cachers_User_at_email_valid?_john2@example.com' => true)
  end

  def test_basic_usage_of_instance_cacher
    user = User.find_by(name: 'John2')
    assert_queries(1){ assert_equal true, user.cacher.email_valid? }
    assert_queries(0){ assert_equal true, user.cacher.email_valid? }
    assert_cache('active_model_cachers_User_at_email_valid?_john2@example.com' => true)
  end
end
