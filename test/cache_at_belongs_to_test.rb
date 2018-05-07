# frozen_string_literal: true
require 'base_test'

class CacheAtBelongsToTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')
    language = user.language

    assert_queries(2){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    user = User.find_by(name: 'John4')
    language = nil

    assert_queries(1){ assert_nil User.cacher_at(user.id).language }
    assert_queries(0){ assert_nil User.cacher_at(user.id).language }
    assert_cache('active_model_cachers_User_at_language_id_4' => ActiveModelCachers::NilObject)

    assert_queries(1){ language = Language.create(id: -1, name: 'ko') }
    assert_cache('active_model_cachers_User_at_language_id_4' => ActiveModelCachers::NilObject)

    user.update_attributes(language: language) # save language_id
    assert_cache({})

    assert_queries(2){ assert_equal 'ko', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'ko', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_4' => -1, 'active_model_cachers_Language_-1' => language)
  ensure
    user.update_attributes(language_id: nil)
    language.delete if language
  end

  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    user = User.find_by(name: 'John1')
    language = user.language

    assert_queries(2){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)

    assert_queries(0){ language.save }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)

    assert_queries(0){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)
  end

  def test_update
    user = User.find_by(name: 'John1')
    language = user.language

    assert_queries(2){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)

    assert_queries(1){ language.update_attributes(name: 'ko') }
    assert_cache("active_model_cachers_User_at_language_id_1" => 2)

    assert_queries(1){ assert_equal 'ko', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_1' => 2, 'active_model_cachers_Language_2' => language)
  ensure
    language.update_attributes(name: 'zh-tw')
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    language = Language.create(id: -3, name: 'ne')
    user = User.create(id: -1, name: 'Pearl', language: language)

    assert_queries(2){ assert_equal 'ne', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'ne', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3, 'active_model_cachers_Language_-3' => language)

    assert_queries(1){ language.destroy }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3)

    assert_queries(1){ assert_nil User.cacher_at(user.id).language }
    assert_queries(0){ assert_nil User.cacher_at(user.id).language }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3, 'active_model_cachers_Language_-3' => ActiveModelCachers::NilObject)
  ensure
    user.delete
    language.delete
  end

  def test_destroy_with_dependent_nullify
    language = Language2.create(id: -3, name: 'ne')
    user = User.create(id: -1, name: 'Pearl', language2: language)

    assert_queries(2){ assert_equal 'ne', User.cacher_at(user.id).language2.name }
    assert_queries(0){ assert_equal 'ne', User.cacher_at(user.id).language2.name }
    assert_cache('active_model_cachers_User_at_language2_id_-1' => -3, 'active_model_cachers_Language2_-3' => language)

    assert_queries(3){ language.destroy } # 1: select user.id to clean cache on user.langauge_id. 2: nullify user.language_id. 3: delete language.
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(user.id).language2 }
    assert_queries(0){ assert_nil User.cacher_at(user.id).language2 }
    assert_cache('active_model_cachers_User_at_language2_id_-1' => ActiveModelCachers::NilObject)
  ensure
    user.delete
    language.delete
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    language = Language.create(id: -3, name: 'ne')
    user = User.create(id: -1, name: 'Pearl', language: language)

    assert_queries(2){ assert_equal 'ne', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'ne', User.cacher_at(user.id).language.name }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3, 'active_model_cachers_Language_-3' => language)

    assert_queries(1){ language.delete }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3)

    assert_queries(1){ assert_nil User.cacher_at(user.id).language }
    assert_queries(0){ assert_nil User.cacher_at(user.id).language }
    assert_cache('active_model_cachers_User_at_language_id_-1' => -3, 'active_model_cachers_Language_-3' => ActiveModelCachers::NilObject)
  ensure
    user.delete
    language.delete
  end
end
