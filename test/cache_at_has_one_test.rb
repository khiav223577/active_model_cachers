require 'base_test'

class CacheAtHasOneTest < BaseTest
  def test_basic_usage
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_create
    profile = nil

    assert_queries(1){ assert_nil User.cacher_at(-1).profile }
    assert_queries(1){ assert_nil User.cacher_at(-1).profile } # FIXME: should be 0 query
    assert_cache({})

    profile = Profile.create(id: -1, point: 3)
    assert_cache({})

    assert_queries(1){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_queries(0){ assert_equal 3, User.cacher_at(-1).profile.point }
    assert_cache('active_model_cachers_Profile_-1' => profile)
  ensure
    profile.destroy if profile
  end

  def test_update_nothing
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    profile.save
    assert_cache('active_model_cachers_Profile_1' => profile)

    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  end

  def test_update
    profile = User.find_by(name: 'John1').profile

    assert_queries(1){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 10, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)

    profile.update_attributes(point: 12)
    assert_cache({})

    assert_queries(1){ assert_equal 12, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 12, User.cacher_at(profile.id).profile.point }
    assert_cache('active_model_cachers_Profile_1' => profile)
  ensure 
    profile.update_attributes(point: 10)
  end

  def test_update_target_which_doesnt_cache_self
    contact = User.find_by(name: 'John1').contact

    assert_queries(1){ assert_equal '12345', User.cacher_at(contact.id).contact.phone }
    assert_queries(0){ assert_equal '12345', User.cacher_at(contact.id).contact.phone }
    assert_cache('active_model_cachers_Contact_1' => contact)

    contact.update_attributes(phone: '12346')
    assert_cache({})

    assert_queries(1){ assert_equal '12346', User.cacher_at(contact.id).contact.phone }
    assert_queries(0){ assert_equal '12346', User.cacher_at(contact.id).contact.phone }
    assert_cache('active_model_cachers_Contact_1' => contact)
  ensure 
    contact.update_attributes(phone: '12345')
  end

  def test_destroy
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    profile.destroy
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile } # FIXME: should be 0 query
    assert_cache({})
  ensure
    profile.destroy
  end

  def test_delete
    profile = Profile.create(point: 13)

    assert_queries(1){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 13, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    profile.delete
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile } # FIXME: should be 0 query
    assert_cache({})
  ensure
    profile.delete
  end

  def test_destroyed_by_dependent_delete
    profile = Profile.create(point: 17)
    user = User.create(profile: profile)

    assert_queries(1){ assert_equal 17, User.cacher_at(profile.id).profile.point }
    assert_queries(0){ assert_equal 17, User.cacher_at(profile.id).profile.point }
    assert_cache("active_model_cachers_Profile_#{profile.id}" => profile)

    user.destroy
    assert_cache({})

    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile }
    assert_queries(1){ assert_nil User.cacher_at(profile.id).profile } # FIXME: should be 0 query
    assert_cache({})
  ensure
    user.destroy
  end
end
