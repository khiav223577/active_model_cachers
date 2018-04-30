require 'active_model_cachers/version'
require 'active_model_cachers/config'
require 'active_model_cachers/cache_service_factory'
require 'active_model_cachers/cacher'
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
    query = ->(id){ find_by(id: id) }
    service_klass = ActiveModelCachers::CacheServiceFactory.create("cacher_key_of_#{self}", &query)
    after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.present? || destroyed? }
    define_singleton_method(:"cachers") do
      service_klass
    end
  end

  def cache_at(column, query = nil)
    reflect = reflect_on_association(column)
    if reflect
      query ||= ->(id){ (reflect.belongs_to? ? reflect.active_record : reflect.klass).find_by(id: id) }
      cache_key = "cacher_key_of_#{reflect.class_name}"
    else
      query ||= ->(id){ where(id: id).limit(1).pluck(column).first }
      cache_key = "cacher_key_of_#{self}_at_#{column}"
    end

    service_klass = ActiveModelCachers::CacheServiceFactory.create(cache_key, &query)
    if reflect
      if reflect.options[:dependent] == :delete
        after_commit ->{ 
          target = association(column).load_target if destroyed? 
          service_klass.instance(target.id).clean_cache if target
        }
      end
    else
      after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.key?(column) || destroyed? }
    end

    cacher = ActiveModelCachers::Cacher.define_cacher_at(self)
    cacher.define_singleton_method(column){ service_klass[@id].get }
    
    define_singleton_method(:"#{column}_cachers") do
      service_klass
    end
  end

  if not method_defined?(:find_by) # define #find_by for Rails 3
    def find_by(*args)
      where(*args).order('').first
    end
  end
end
