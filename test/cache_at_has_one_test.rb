# frozen_string_literal: true
require 'base_test'

class CacheAtHasOneTest < BaseTest
  def test_basic_usage
    user = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => user.profile)
  end

  def test_basic_usage_of_instance_cacher
    user = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 10, user.cacher.profile.point }
    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => user.profile)
  end

  def test_instance_cacher_without_association_cache
    user1 = User.find_by(name: 'John2')
    user2 = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 10, user1.cacher.profile.point }
    assert_queries(0){ assert_equal 10, user2.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => user1.profile)
  end

  def test_instance_cacher_to_use_loaded_associations
    user = User.find_by(name: 'John2')
    profile = user.profile

    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)
  end

  def test_instance_cacher_to_use_preloaded_associations
    user = User.includes(:profile).find_by(name: 'John2')

    assert_queries(0){ assert_equal 10, user.cacher.profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => user.profile)
  end

  # ----------------------------------------------------------------
  # ● Create
  # ----------------------------------------------------------------
  def test_create
    profile = nil

    assert_queries(1){ assert_nil User.cacher_at(-1).profile }
    assert_queries(0){ assert_nil User.cacher_at(-1).profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-1' => ActiveModelCachers::NilObject)

    assert_queries(1){ profile = Profile.create(id: -2, user_id: -1, point: 3) }
    assert_cache({})

    assert_queries(1){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_queries(0){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_-1' => profile)
  ensure
    profile.destroy if profile
  end

  # ----------------------------------------------------------------
  # ● Assign
  # ----------------------------------------------------------------
  def test_assign_association
    user = User.create(id: -1)
    profile = Profile.create(id: -2, point: 3)

    assert_queries(1){ assert_nil user.cacher.profile }
    assert_queries(0){ assert_nil user.cacher.profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-1' => ActiveModelCachers::NilObject)

    assert_queries(1){ user.profile = profile; user.save }
    assert_cache({})

    assert_queries(0){ assert_equal profile, user.cacher.profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-1' => profile)
  ensure
    user.delete if user
    profile.delete if profile
  end

  # ----------------------------------------------------------------
  # ● Clean
  # ----------------------------------------------------------------
  def test_clean
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_by_user_id_2', profile)
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)

    assert_queries(0){ User.cacher_at(2).clean_profile }
    assert_cache({})
  end

  def test_clean2
    profile = User.find_by(name: 'John2').profile

    Rails.cache.write('active_model_cachers_Profile_by_user_id_2', profile)
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)

    assert_queries(0){ User.cacher_at(2).clean(:profile) }
    assert_cache({})
  end

  def test_clean_in_instance_cacher
    user = User.find_by(name: 'John2')

    Rails.cache.write('active_model_cachers_Profile_by_user_id_2', user.profile)
    assert_cache('active_model_cachers_Profile_by_user_id_2' => user.profile)

    assert_queries(0){ user.cacher.clean_profile }
    assert_cache({})
  end
  # ----------------------------------------------------------------
  # ● Update
  # ----------------------------------------------------------------
  def test_update_nothing
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)

    assert_queries(0){ profile.save }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)

    assert_queries(0){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)
  end

  def test_update
    profile = User.find_by(name: 'John2').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)

    assert_queries(1){ profile.update(point: 12) }
    assert_cache({})

    assert_queries(1){ assert_equal 12, User.cacher_at(2).profile.point }
    assert_queries(0){ assert_equal 12, User.cacher_at(2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_2' => profile)
  ensure
    profile.update(point: 10)
  end

  def test_update_target_which_doesnt_have_cacher
    contact = User.find_by(name: 'John1').contact

    # make sure Contact doesn't have cacher to test that after_commit callback on Contact is registered by the cacher of User.
    assert_raises NoMethodError do
      contact.class.cacher
    end

    assert_queries(1){ assert_equal '12345', User.cacher_at(1).contact.phone }
    assert_queries(0){ assert_equal '12345', User.cacher_at(1).contact.phone }
    assert_cache('active_model_cachers_Contact_by_user_id_1' => contact)

    assert_queries(1){ contact.update(phone: '12346') }
    assert_cache({})

    assert_queries(1){ assert_equal '12346', User.cacher_at(1).contact.phone }
    assert_queries(0){ assert_equal '12346', User.cacher_at(1).contact.phone }
    assert_cache('active_model_cachers_Contact_by_user_id_1' => contact)
  ensure
    contact.update(phone: '12345')
  end

  # ----------------------------------------------------------------
  # ● Destroy
  # ----------------------------------------------------------------
  def test_destroy
    profile = Profile.create(id: -3, user_id: -2, point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(-2).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(-2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => profile)

    assert_queries(1){ profile.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(-2).profile }
    assert_queries(0){ assert_nil User.cacher_at(-2).profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  # ----------------------------------------------------------------
  # ● Delete
  # ----------------------------------------------------------------
  def test_delete
    profile = Profile.create(id: -3, user_id: -2, point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(-2).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(-2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => profile)

    assert_queries(1){ profile.delete }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(-2).profile }
    assert_queries(0){ assert_nil User.cacher_at(-2).profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => ActiveModelCachers::NilObject)
  ensure
    profile.destroy
  end

  def test_destroyed_by_dependent_delete
    profile = Profile.create(id: -3, user_id: -2, point: 17)
    user = User.create(id: -2, profile: profile)

    assert_queries(1){ assert_equal 17, User.cacher_at(-2).profile.point }
    assert_queries(0){ assert_equal 17, User.cacher_at(-2).profile.point }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => profile)

    assert_queries(user_destroy_dependents_count){ user.destroy }
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(-2).profile }
    assert_queries(0){ assert_nil User.cacher_at(-2).profile }
    assert_cache('active_model_cachers_Profile_by_user_id_-2' => ActiveModelCachers::NilObject)
  ensure
    user.destroy
  end
end
