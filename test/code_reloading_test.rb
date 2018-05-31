# frozen_string_literal: true
require 'base_test'

class CodeReloadingTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John2').profile

    origin_profile = Profile
    Object.send(:remove_const, :Profile)
    load 'lib/models/profile.rb'

    assert_queries(1){ assert_equal 10, Profile.cacher.find_by(token: 'tt9wav').point }
    assert_queries(0){ assert_equal 10, Profile.cacher.find_by(token: 'tt9wav').point }
    assert_cache('active_model_cachers_Profile_by_token_tt9wav' => profile)

  ensure
    Object.send(:const_set, :Profile, origin_profile) if origin_profile
  end
end
