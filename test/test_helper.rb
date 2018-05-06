# frozen_string_literal: true
require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_model_cachers'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  "adapter"  => "sqlite3",
  "database" => ":memory:"
)

if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('5') and ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks=)
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

require 'lib/rails_cache'
require 'lib/seeds'

def assert_queries(expected_count)
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, payload|
    sqls << "  ● #{payload[:sql]}" if payload[:sql] !~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION)/i
  end
  yield
  if expected_count != sqls.size # show all sql queries if query count doesn't equal to expected count.
    assert_equal "expect #{expected_count} queries, but have #{sqls.size}", "\n#{sqls.join("\n").gsub('"', "'")}\n"
  end
  assert_equal expected_count, sqls.size
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end

def assert_cache(data)
  assert_equal(data, Rails.cache.all_data)
end
