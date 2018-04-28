require 'test_helper'

class ActiveModelCachersTest < Minitest::Test
  def setup
    Rails.cache.clear
  end

  def test_cache_profile
    profile = User.find_by(name: 'John1').profile
    cacher = User.profile_cachers[profile.id]

    assert_queries(1) do
      assert_equal 10, cacher.get.point
      assert_equal({'cacher_key_of_User_at_profile_1' => profile}, Rails.cache.all_data)  
    end

    assert_queries(0) do
      assert_equal 10, cacher.get.point
      assert_equal({'cacher_key_of_User_at_profile_1' => profile}, Rails.cache.all_data)
    end
  end

  def test_cache_profile_attribute
    profile = User.find_by(name: 'John1').profile
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1) do
      assert_equal 10, cacher.get
      assert_equal({'cacher_key_of_Profile_at_point_1' => 10}, Rails.cache.all_data)
    end

    assert_queries(0) do
      assert_equal 10, cacher.get
      assert_equal({'cacher_key_of_Profile_at_point_1' => 10}, Rails.cache.all_data)
    end
  end

  def test_clean_profile_attribute_cache_after_update
    profile = User.find_by(name: 'John2').profile
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1) do
      assert_equal 30, cacher.get
      assert_equal({'cacher_key_of_Profile_at_point_2' => 30}, Rails.cache.all_data)
    end

    profile.update(point: 32)
    assert_equal({}, Rails.cache.all_data)

    assert_queries(1) do
      assert_equal 32, cacher.get
      assert_equal({'cacher_key_of_Profile_at_point_2' => 32}, Rails.cache.all_data)
    end
  end

  def test_clean_profile_attribute_cache_after_destroy
    profile = Profile.create(id: 0, point: 30)
    cacher = Profile.point_cachers[profile.id]

    assert_queries(1) do
      assert_equal 30, cacher.get
      assert_equal({'cacher_key_of_Profile_at_point_0' => 30}, Rails.cache.all_data)
    end

    profile.destroy
    assert_equal({}, Rails.cache.all_data)

    assert_queries(1) do
      assert_nil cacher.get
      assert_equal({}, Rails.cache.all_data)
    end
  end
end
