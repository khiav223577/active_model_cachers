require 'active_model_cachers/version'
require 'active_model_cachers/config'
require 'active_model_cachers/cache_service_factory'
require 'active_model_cachers/cacher'
require 'active_model_cachers/hook_dependencies'
require 'active_model_cachers/hook_model_delete'
require 'active_record'
require 'active_record/relation'

module ActiveModelCachers
  def self.config
    @config ||= Config.new
    yield(@config) if block_given?
    return @config
  end
end

class << ActiveRecord::Base
  def cache_self
    service_klass = ActiveModelCachers::CacheServiceFactory.create_for_active_model(self, nil)
    after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.present? || destroyed? }
  end

  def cache_at(column, query = nil)
    service_klass = ActiveModelCachers::CacheServiceFactory.create_for_active_model(self, column, &query)
    reflect = reflect_on_association(column)
    if reflect
      if reflect.options[:dependent] == :delete
        after_commit ->{ 
          target = association(column).load_target if destroyed? 
          service_klass.instance(target.id).clean_cache if target
        }
      end
      ActiveSupport::Dependencies.onload(reflect.class_name) do
        after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.present? || destroyed? }
      end
    else
      after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.key?(column) || destroyed? }
      on_delete{|id| service_klass.instance(id).clean_cache }
    end
  end

  if not method_defined?(:find_by) # define #find_by for Rails 3
    def find_by(*args)
      where(*args).order('').first
    end
  end
end
