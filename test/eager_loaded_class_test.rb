# frozen_string_literal: true
require 'base_test'

class EagerLoadedTest < BaseTest
  def test_update
    user = EagerLoaded::User.first

    assert_queries(1){ assert_equal 19, user.cacher.profile.point }
    assert_queries(0){ assert_equal 19, user.cacher.profile.point }
    assert_cache('active_model_cachers_EagerLoaded::Profile_by_user_id_1' => user.profile)

    assert_cache_queries(2) do # Delete cache at self and at self_by_user_id
      assert_queries(1){ user.profile.update_attributes(point: 12) }
    end
    assert_cache({})

    user = EagerLoaded::User.first
    assert_queries(1){ assert_equal 12, user.cacher.profile.point }
    assert_queries(0){ assert_equal 12, user.cacher.profile.point }
    assert_cache('active_model_cachers_EagerLoaded::Profile_by_user_id_1' => user.profile)
  ensure
    user.profile.update_attributes(point: 19)
  end

  def test_update_belongs_to_association
    user = EagerLoaded::User.find_by(name: 'Pearl')
    language = user.language

    assert_queries(2){ assert_equal 'zh-tw', EagerLoaded::User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'zh-tw', EagerLoaded::User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_EagerLoaded::User_at_language_id_1' => 2, 'active_model_cachers_EagerLoaded::Language_2' => language)

    assert_queries(1){ language.update_attributes(name: 'ko') }
    assert_cache("active_model_cachers_EagerLoaded::User_at_language_id_1" => 2)

    assert_queries(1){ assert_equal 'ko', EagerLoaded::User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_EagerLoaded::User_at_language_id_1' => 2, 'active_model_cachers_EagerLoaded::Language_2' => language)
  ensure
    language.update_attributes(name: 'zh-tw')
  end
end
