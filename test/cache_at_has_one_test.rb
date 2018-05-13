# frozen_string_literal: true
require 'base_test'

class CacheAtHasOneTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_basic_usage_of_instance_cacher
    user = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 10, user.cacher.profile.point }
    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_1' => user.profile)
  end

  def test_instance_cacher_without_association_cache
    user1 = User.find_by(name: 'John2')
    user2 = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 10, user1.cacher.profile.point }
    assert_queries(0){ assert_equal 10, user2.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_1' => user1.profile)
  end

  def test_instance_cacher_to_use_loaded_associations
    user = User.find_by(name: 'John2')
    profile = user.profile

    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_instance_cacher_to_use_preloaded_associations
    user = User.includes(:profile).find_by(name: 'John2')

    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_1' => user.profile)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    profile = nil

    assert_queries(1){ assert_nil User.cacher_at(-1).profile }
    assert_queries(0){ assert_nil User.cacher_at(-1).profile }
    assert_cache('active_model_cachers_Profile_-1' => ActiveModelCachers::NilObject)

    assert_queries(1){ profile = Profile.create(id: -1, point: 3) }
    assert_cache({})

    assert_queries(1){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_queries(0){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_cache('active_model_cachers_Profile_-1' => profile)
  ensure
    profile.destroy if profile
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_1', profile)
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ User.cacher_at(profile.id).clean_profile }
    assert_cache({})
  end

  def test_clean2
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_1', profile)
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ User.cacher_at(profile.id).clean(:profile) }
    assert_cache({})
  end

  def test_clean_in_instance_cacher
    user = User.find_by(name: 'John2')

    Rails.cache.write('active_model_cachers_Profile_1', user.profile)
    assert_cache('active_model_cachers_Profile_1' => user.profile)

    assert_queries(0){ user.cacher.clean_profile }
    assert_cache({})
  end
  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ profile.save }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(1){ profile.update_attributes(point: 12) }
    assert_cache({})

    assert_queries(1){ assert_equal 12, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 12, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  ensure
    profile.update_attributes(point: 10)
  end

  def test_update_target_which_doesnt_have_cacher
    contact = User.find_by(name: 'John1').contact

    # make sure Contact doesn't have cacher to test that after_commit callback on Contact is registered by the cacher of User.
    assert_raises NoMethodError do
      contact.class.cacher
    end

    assert_queries(1){ assert_equal '12345', User.cacher_at(contact.id).contact.phone }
    assert_queries(0){ assert_equal '12345', User.cacher_at(contact.id).contact.phone }
    assert_cache('active_model_cachers_Contact_1' => contact)

    assert_queries(1){ contact.update_attributes(phone: '12346') }
    assert_cache({})

    assert_queries(1){ assert_equal '12346', User.cacher_at(contact.id).contact.phone }
    assert_queries(0){ assert_equal '12346', User.cacher_at(contact.id).contact.phone }
    assert_cache('active_model_cachers_Contact_1' => contact)
  ensure
    contact.update_attributes(phone: '12345')
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    assert_queries(1){ profile.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(0){ assert_nil User.cacher_at(profile.id).profile }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    assert_queries(1){ profile.delete }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(0){ assert_nil User.cacher_at(profile.id).profile }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    profile.delete
  end

  def test_destroyed_by_dependent_delete
    profile = Profile.create(point: 17)
    user = User.create(profile: profile)

    assert_queries(1){ assert_equal 17, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 17, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    assert_queries(3){ user.destroy } # 1. delete user. 2: delete profile by dependent. 3: delete contact by dependent.
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(0){ assert_nil User.cacher_at(profile.id).profile }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => ActiveModelCachers::NilObject)
  ensure
    user.destroy
  end
end
