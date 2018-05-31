# frozen_string_literal: true
require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    @key_class_mapping = {}
    @cache_key_klass_mapping = {}

    class << self
      def has_cacher?(attr)
        return (@key_class_mapping[get_cache_key(attr)] != nil)
      end

      def create_for_active_model(attr, query, current_klass)
        class_name, _ = attr.extract_class_and_column
        cache_key = get_cache_key(attr)
        clean_klass_cache_after_reloaded!(cache_key, current_klass) if current_klass.name == class_name.to_s
        return create(cache_key, query)
      end

      def create(cache_key, query)
        @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)
          klass.cache_key = cache_key
          klass.query = query
          klass.instance_variable_set(:@callbacks_defined, false) # to remove warning: instance variable @callbacks_defined not initialized
          next klass
        }[]
      end

      private

      def get_cache_key(attr)
        class_name, column = attr.extract_class_and_column
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        foreign_key = attr.foreign_key(reverse: true)
        return "active_model_cachers_#{class_name}_by_#{foreign_key}" if foreign_key and foreign_key.to_s != 'id'
        return "active_model_cachers_#{class_name}"
      end

      def clean_klass_cache_after_reloaded!(cache_key, current_klass)
        origin_klass, @cache_key_klass_mapping[cache_key] = @cache_key_klass_mapping[cache_key], current_klass
        @key_class_mapping[cache_key] = nil if origin_klass and origin_klass != current_klass # when code reloaded in development.
      end
    end
  end
end
