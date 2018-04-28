require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_model_cachers'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  "adapter"  => "sqlite3",
  "database" => ":memory:"
)

ActiveRecord::Base.raise_in_transactional_callbacks = true
require 'rails_cache'
require 'seeds'

def assert_queries(expected_count)
  count = 0
  subscriber = ActiveSupport::Notifications.subscribe('sql.active_record'){ count += 1 }
  yield
  assert_equal expected_count, count
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end
    
