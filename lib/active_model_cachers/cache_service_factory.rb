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

      def create_for_active_model(attr, query)
        cache_key = get_cache_key(attr)

        klass = @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)
          klass.cache_key = cache_key
          klass.query_mapping = {}
          klass.instance_variable_set(:@callbacks_defined, false) # to remove warning: instance variable @callbacks_defined not initialized
          next klass
        }[]

        klass.query_mapping[attr] = query
        return klass
      end

      def set_klass_to_mapping(attr, current_klass)
        cache_key = get_cache_key(attr)
        changed = clean_klass_cache_if_reloaded!(cache_key, current_klass, attr)
        @cache_key_klass_mapping[cache_key] = current_klass
        return changed
      end

      private

      def get_cache_key(attr)
        class_name, column = attr.extract_class_and_column
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        foreign_key = attr.foreign_key(reverse: true)
        return "active_model_cachers_#{class_name}_by_#{foreign_key}" if foreign_key and foreign_key.to_s != 'id'
        return "active_model_cachers_#{class_name}"
      end

      def clean_klass_cache_if_reloaded!(cache_key, current_klass, attr)
        origin_klass, @cache_key_klass_mapping[cache_key] = @cache_key_klass_mapping[cache_key], current_klass
        return false if origin_klass == nil or origin_klass == current_klass # when code reloaded in development.
        @key_class_mapping[cache_key] = nil
        return true
      end
    end
  end
end
