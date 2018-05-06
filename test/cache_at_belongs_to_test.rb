require 'base_test'

class CacheAtBelongsToTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John1')
    language = user.language

    assert_queries(2){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'zh-tw', User.cacher_at(user.id).language.name }
    assert_cache(
      "active_model_cachers_User_at_language_id_#{user.id}" => language.id,
      "active_model_cachers_Language_#{language.id}" => language,
    )
  end

  def test_create
    user = User.find_by(name: 'John4')

    assert_queries(1){ assert_nil User.cacher_at(user.id).language }
    assert_queries(0){ assert_nil User.cacher_at(user.id).language }
    assert_cache("active_model_cachers_User_at_language_id_#{user.id}" => ActiveModelCachers::NilObject)

    language = Language.create(id: -1, user: user, name: 'ko')
    assert_cache({})

    assert_queries(2){ assert_equal 'ko', User.cacher_at(user.id).language.name }
    assert_queries(0){ assert_equal 'ko', User.cacher_at(user.id).language.name }
    assert_cache(
      "active_model_cachers_User_at_language_id_#{user.id}" => language.id,
      "active_model_cachers_Language_#{language.id}" => language,
    )
  ensure
    language.delete if language
  end
end
