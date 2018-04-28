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
