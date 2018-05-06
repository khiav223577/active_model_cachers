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

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
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

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
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

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete_target
    user = User.create(name: 'John5')
    post = PostWithoutCache.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post_without_cache? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post_without_cache? }
    assert_cache("active_model_cachers_User_at_has_post_without_cache?_#{user.id}" => true)

    assert_queries(2){ post.delete } # select post.user_id and then delete post.
    assert_cache({})

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_cache("active_model_cachers_User_at_has_post_without_cache?_#{user.id}" => ActiveModelCachers::FalseObject)
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_with_cache_self_but_not_cached
    user = User.create(name: 'John5')
    post = Post.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(2){ post.delete } # select post.user_id and then delete post.
    assert_cache({})
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_with_cache_self_and_cached
    user = User.create(name: 'John5')
    post = Post.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(1){ assert_equal post, Post.cacher_at(post.id).self }
    assert_queries(0){ assert_equal post, Post.cacher_at(post.id).self }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true, "active_model_cachers_Post_#{post.id}" => post)

    assert_queries(1){ post.delete } # select post.user_id from cache and then delete post.
    assert_cache({})
  ensure
    user.delete
    post.delete
  end
end
