# frozen_string_literal: true
require 'base_test'

class OverrideAssociationMethodTest < BaseTest
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
end
