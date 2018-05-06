# frozen_string_literal: true
require 'test_helper'

class BaseTest < Minitest::Test
  def setup
    Rails.cache.clear
    RequestStore.clear!
  end
end
