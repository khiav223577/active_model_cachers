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

  def test_create
    user = User.find_by(name: 'John4')

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_4' => ActiveModelCachers::FalseObject)

    post = Post.create(user: user)
    assert_cache({})

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_4' => true)
  ensure
    post.destroy if post
  end

  def test_destroy
    user = User.create(name: 'John5')
    post = Post.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    post.destroy
    assert_cache({})

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => ActiveModelCachers::FalseObject)
  ensure
    user.delete
    post.delete
  end

  def test_delete
    user = User.create(name: 'John5')
    post = Post.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(2){ post.delete } # one delete and one select
    assert_cache({})

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => ActiveModelCachers::FalseObject)
  ensure
    user.delete
    post.delete
  end
end
