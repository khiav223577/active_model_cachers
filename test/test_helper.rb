# frozen_string_literal: true
require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_record'
if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('5') and ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks=)
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

require 'active_model_cachers'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  "adapter"  => "sqlite3",
  "database" => ":memory:"
)

require 'lib/rails_cache'
require 'lib/seeds'

def user_destroy_dependents_count
  # 1. delete user.
  # 2: delete profile by dependent.
  # 3: delete contact by dependent.
  # 4: delete user_achievements by dependent.
  4
end

def assert_queries(expected_count, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
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

def assert_cache_queries(expected_count, &block)
  assert_queries(expected_count, 'cache.active_record', &block)
end

def reload_models(*klasses) # EX: klasses = [User, Post]
  origin_klasses = klasses.map{|klass| [klass.name.to_sym, klass] }.to_h
  origin_klasses.each{|class_name, _| Object.send(:remove_const, class_name) }

  origin_cache = ActiveSupport::Dependencies::Reference
  origin_loaded = ActiveSupport::Dependencies.loaded
  ActiveSupport::Dependencies.loaded = []
  ActiveSupport::Dependencies.send(:remove_const, :Reference)
  ActiveSupport::Dependencies.const_set(:Reference, ActiveSupport::Dependencies::ClassCache.new)

  yield
ensure
  ActiveSupport::Dependencies.loaded = origin_loaded if origin_loaded

  if origin_cache
    ActiveSupport::Dependencies.send(:remove_const, :Reference)
    ActiveSupport::Dependencies.const_set(:Reference, origin_cache)
  end

  if origin_klasses
    origin_klasses.each do |class_name, klass|
      Object.send(:remove_const, class_name)
      Object.send(:const_set, class_name, klass)
    end
  end
end
