# frozen_string_literal: true
require 'base_test'

class CacheAtHasManyTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')
    posts = user.posts

    assert_queries(1){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_queries(0){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_cache('active_model_cachers_User_at_posts_1' => posts)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John1')
    posts = user.posts
    new_post = nil

    assert_queries(1){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_queries(0){ assert_equal 3, User.cacher_at(user.id).posts.size }
    assert_cache('active_model_cachers_User_at_posts_1' => posts)

    assert_queries(1){ new_post = Post.create(id: -1, user: user) }
    assert_cache({})

    assert_queries(1){ assert_equal 4, User.cacher_at(user.id).posts.size }
    assert_queries(0){ assert_equal 4, User.cacher_at(user.id).posts.size }
    assert_cache('active_model_cachers_User_at_posts_1' => [new_post, *posts])
  ensure
    new_post.delete if new_post
  end

  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    user = User.find_by(name: 'John4')
    post = Post.create(id: -1, user: user)

    assert_queries(1){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])

    assert_queries(0){ post.save }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])

    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])
  ensure
    post.delete
  end

  def test_update_title
    user = User.find_by(name: 'John4')
    post = Post.create(id: -1, user: user)

    assert_queries(1){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])

    assert_queries(1){ post.update_attributes(title: '學生退出校園') }
    assert_cache({})

    assert_queries(1){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])
  ensure
    post.delete
  end

  def test_update_others_post_title
    user1 = User.find_by(name: 'John4')
    user2 = User.find_by(name: 'John1')
    post = Post.create(id: -1, user: user2)

    assert_queries(1){ assert_equal [], User.cacher_at(user1.id).posts }
    assert_queries(0){ assert_equal [], User.cacher_at(user1.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [])

    assert_queries(1){ post.update_attributes(title: '學生退出校園') }
    assert_cache('active_model_cachers_User_at_posts_4' => [])

    assert_queries(0){ assert_equal [], User.cacher_at(user1.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [])
  ensure
    post.delete
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    user = User.find_by(name: 'John4')
    post = Post.create(id: -1, user: user)

    assert_queries(1){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])

    assert_queries(1){ post.destroy }
    assert_cache({})

    assert_queries(1){ assert_equal [], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [])
  ensure
    post.delete
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    user = User.find_by(name: 'John4')
    post = Post.create(id: -1, user: user)

    assert_queries(1){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [post], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [post])

    assert_queries(2){ post.delete }
    assert_cache({})

    assert_queries(1){ assert_equal [], User.cacher_at(user.id).posts }
    assert_queries(0){ assert_equal [], User.cacher_at(user.id).posts }
    assert_cache('active_model_cachers_User_at_posts_4' => [])
  ensure
    post.delete
  end
end
