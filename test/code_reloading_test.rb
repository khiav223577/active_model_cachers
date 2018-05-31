# frozen_string_literal: true
require 'base_test'

class CodeReloadingTest < BaseTest
  def test_self
    profile1 = Profile.find_by(token: 'tt9wav')

    origin_profile_klass = Profile
    Object.send(:remove_const, :Profile)
    load 'lib/models/profile.rb'

    profile2 = Profile.find_by(token: 'tt9wav')

    assert_queries(1){ assert_equal 10, Profile.cacher.find_by(token: 'tt9wav').point }
    assert_queries(0){ assert_equal 10, Profile.cacher.find_by(token: 'tt9wav').point }
    assert_cache('active_model_cachers_Profile_by_token_tt9wav' => profile2)
    refute_equal(profile1, profile2)
  ensure
    if origin_profile_klass
      Object.send(:remove_const, :Profile)
      Object.send(:const_set, :Profile, origin_profile_klass)
    end
  end

  def test_association
    posts1 = User.first.posts

    origin_post_klass = Post
    Object.send(:remove_const, :Post)
    load 'lib/models/post.rb'

    posts2 = User.first.posts

    assert_queries(1){ assert_equal 3, User.cacher_at(1).posts.size }
    assert_queries(0){ assert_equal 3, User.cacher_at(1).posts.size }
    assert_cache('active_model_cachers_User_at_posts_1' => posts2)
    refute_equal(posts1, posts2)
  ensure
    if origin_post_klass
      Object.send(:remove_const, :Post)
      Object.send(:const_set, :Post, origin_post_klass)
    end
  end
end
