# frozen_string_literal: true
require 'active_model_cachers/version'
require 'active_model_cachers/config'
require 'active_model_cachers/cache_service_factory'
require 'active_record'
require 'active_record/relation'
require 'active_model_cachers/active_record/extension'

module ActiveModelCachers
  def self.config
    @config ||= Config.new
    yield(@config) if block_given?
    return @config
  end
end

ActiveRecord::Base.send(:extend, ActiveModelCachers::ActiveRecord::Extension)

gem_version = Gem::Version.new(ActiveRecord::VERSION::STRING)
if gem_version < Gem::Version.new('4')
  require 'active_model_cachers/patches/patch_rails_3'
end

# https://github.com/rails/rails/pull/29018
if gem_version >= Gem::Version.new('5') && gem_version < Gem::Version.new('5.2')
  require 'active_model_cachers/patches/uninitialized_attribute'
end

