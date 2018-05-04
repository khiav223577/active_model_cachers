require 'base_test'

class CacheUserCountTest < BaseTest
  def test_basic_usage
    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)

    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  end

  def test_create
    user = nil
    
    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)

    user = User.create(id: -1)
    assert_cache({})

    assert_queries(1){ assert_equal 5, User.cacher.count }
    assert_queries(0){ assert_equal 5, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 5)
  ensure
    user.destroy if user
  end

  def test_update_nothing
    user = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)

    user.save
    assert_cache('active_model_cachers_User_at_count' => 4)

    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  end

  def test_update
    user = User.find_by(name: 'John2')

    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)

    user.update_attributes(name: '??')
    assert_cache('active_model_cachers_User_at_count' => 4)

    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  ensure
    user.update_attributes(name: 'John2')
  end

  def test_destroy
    user = User.create

    assert_queries(1){ assert_equal 5, User.cacher.count }
    assert_queries(0){ assert_equal 5, User.cacher.count }
    assert_cache("active_model_cachers_User_at_count" => 5)

    user.destroy
    assert_cache({})

    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  ensure
    user.destroy
  end

  def test_delete
    user = User.create

    assert_queries(1){ assert_equal 5, User.cacher.count }
    assert_queries(0){ assert_equal 5, User.cacher.count }
    assert_cache("active_model_cachers_User_at_count" => 5)

    user.delete
    assert_cache({})

    assert_queries(1){ assert_equal 4, User.cacher.count }
    assert_queries(0){ assert_equal 4, User.cacher.count }
    assert_cache('active_model_cachers_User_at_count' => 4)
  ensure
    user.destroy
  end

  def test_destroyed_by_dependent_delete
    # TODO
  end
end
