require 'active_model_cachers/version'
require 'active_model_cachers/cache_service_factory'
require 'active_record'
require 'active_record/relation'


class << ActiveRecord::Base
  def cache_at(column, query)
    service_klass = ActiveModelCachers::CacheServiceFactory.create(&query)
    after_commit ->{ service_klass.instance.clean_cache if previous_changes.key?(column) || destroyed? }

    define_singleton_method(:"#{column}_cachers") do
      service_klass
    end
  end
end
