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

      def create_for_active_model(attr, query)
        cache_key = get_cache_key(attr)
        service_klass = create(cache_key, query)
        return service_klass
      end

      def create(cache_key, query)
        @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)
          klass.cache_key = cache_key
          klass.query = query
          next klass
        }[]
      end

      private

      def get_cache_key(attr)
        class_name, column = (attr.single_association? ? [attr.class_name, nil] : [attr.klass, attr.column])
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        return "active_model_cachers_#{class_name}_by_#{attr.primary_key}" if attr.primary_key and attr.primary_key.to_s != 'id'
        return "active_model_cachers_#{class_name}"
      end
    end
  end
end
