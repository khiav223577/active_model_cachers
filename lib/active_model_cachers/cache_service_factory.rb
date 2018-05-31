# frozen_string_literal: true
require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    @key_class_mapping = {}

    class << self
      def has_cacher?(attr)
        return (@key_class_mapping[get_cache_key(attr)] != nil)
      end

      def create_for_active_model(active_model_klass, attr, query)
        cache_key = get_cache_key(attr)
        service_klass = create(cache_key, active_model_klass, query)
        if service_klass.active_model_klass != active_model_klass
          @key_class_mapping[cache_key] = nil
          return create_for_active_model(active_model_klass, attr, query)
        end
        return service_klass
      end

      def create(cache_key, active_model_klass, query)
        @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)
          klass.cache_key = cache_key
          klass.query = query
          klass.active_model_klass = active_model_klass
          klass.instance_variable_set(:@callbacks_defined, false) # to remove warning: instance variable @callbacks_defined not initialized
          next klass
        }[]
      end

      private

      def get_cache_key(attr)
        class_name, column = (attr.single_association? ? [attr.class_name, nil] : [attr.klass, attr.column])
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        foreign_key = attr.foreign_key(reverse: true)
        return "active_model_cachers_#{class_name}_by_#{foreign_key}" if foreign_key and foreign_key.to_s != 'id'
        return "active_model_cachers_#{class_name}"
      end
    end
  end
end
