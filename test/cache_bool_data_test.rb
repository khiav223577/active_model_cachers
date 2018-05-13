# frozen_string_literal: true
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

  def test_basic_usage_of_instance_cacher
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_post? }
    assert_queries(0){ assert_equal true, user.cacher.has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_1' => true)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John4')
    post = nil

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_4' => ActiveModelCachers::FalseObject)

    assert_queries(1){ post = Post.create(user: user) }
    assert_cache({})

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_4' => true)
  ensure
    post.destroy if post
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_1' => true)

    assert_queries(0){ User.cacher_at(user.id).clean_has_post? }
    assert_cache({})
  end

  def test_clean_in_instance_cacher
    user = User.find_by(name: 'John1')

    assert_queries(1){ assert_equal true, user.cacher.has_post? }
    assert_queries(0){ assert_equal true, user.cacher.has_post? }
    assert_cache('active_model_cachers_User_at_has_post?_1' => true)

    assert_queries(0){ user.cacher.clean_has_post? }
    assert_cache({})
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

    assert_queries(1){ post.destroy }
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

    assert_queries(1){ post.delete }
    assert_cache({})

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_cache("active_model_cachers_User_at_has_post_without_cache?_#{user.id}" => ActiveModelCachers::FalseObject)
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_without_model
    user = User.create(name: 'John5')
    post = PostWithoutCache.create(id: -2, user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post_without_cache? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post_without_cache? }
    assert_cache("active_model_cachers_User_at_has_post_without_cache?_#{user.id}" => true)

    assert_queries(2){ PostWithoutCache.delete(-2) } # 1: select post.user_id to clean cache on user.posts. 2: delete post.
    assert_cache({})

    assert_queries(1){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_queries(0){ assert_equal false, User.cacher_at(user.id).has_post_without_cache? }
    assert_cache("active_model_cachers_User_at_has_post_without_cache?_#{user.id}" => ActiveModelCachers::FalseObject)
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_with_cache_self
    user = User.create(name: 'John5')
    post = Post.create(user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(1){ post.delete }
    assert_cache({})
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_with_cache_self_but_without_model_and_not_cached
    user = User.create(name: 'John5')
    post = Post.create(id: -2, user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(2){ Post.delete(-2) } # 1: select post.user_id to clean cache on user.posts. 2: delete post.
    assert_cache({})
  ensure
    user.delete
    post.delete
  end

  def test_delete_target_with_cache_self_but_without_model_and_cached
    user = User.create(name: 'John5')
    post = Post.create(id: -2, user: user)

    assert_queries(1){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_queries(0){ assert_equal true, User.cacher_at(user.id).has_post? }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true)

    assert_queries(1){ assert_equal post, Post.cacher_at(post.id).self }
    assert_queries(0){ assert_equal post, Post.cacher_at(post.id).self }
    assert_cache("active_model_cachers_User_at_has_post?_#{user.id}" => true, "active_model_cachers_Post_#{post.id}" => post)

    assert_queries(1){ Post.delete(-2) } # 1: select post.user_id from Post.cache_self to clean cache on user.posts. 2: delete post.
    assert_cache({})
  ensure
    user.delete
    post.delete
  end
end
