# frozen_string_literal: true
require 'base_test'

class OverrideAssociationMethodTest < BaseTest
  # ----------------------------------------------------------------
  # ● Singleton method
  # ----------------------------------------------------------------
  def test_define_singleton_method_on_association
    user = User.find_by(name: 'John2')
    profile = user.profile

    def profile.test
    end

    assert_queries(0){ assert_equal 10, User.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)
  end

  # ----------------------------------------------------------------
  # ● Override original association method
  # ----------------------------------------------------------------
  def test_override_belongs_to_association_method
    user = User.find_by(name: 'John2')
    language = user.language

    counter = 1
    user.define_singleton_method(:language) do
      counter += 1
      raise SystemStackError.new('stack level too deep') if counter > 3
      next cacher.language
    end

    assert_queries(0){ assert_equal 'zh-tw', user.cacher.language.name }
    assert_cache('active_model_cachers_User_at_language_id_2' => 2, 'active_model_cachers_Language_2' => language)
  end

  def test_override_has_one_association_method
    user = User.find_by(name: 'John2')
    profile = user.profile

    counter = 1
    user.define_singleton_method(:profile) do
      counter += 1
      raise SystemStackError.new('stack level too deep') if counter > 3
      next cacher.profile
    end

    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)
  end

  def test_override_has_many_association_method
    user = User.find_by(name: 'John2')
    posts = user.posts.to_a

    counter = 1
    user.define_singleton_method(:posts) do
      counter += 1
      raise SystemStackError.new('stack level too deep') if counter > 3
      next cacher.posts
    end

    assert_queries(0){ assert_equal 2, user.cacher.posts.size }
    assert_cache('active_model_cachers_User_at_posts_2' => posts)
  end
end
