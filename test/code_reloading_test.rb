# frozen_string_literal: true
require 'base_test'

class CodeReloadingTest < BaseTest
  def test_basic_usage
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
end
