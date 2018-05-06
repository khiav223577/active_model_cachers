# frozen_string_literal: true
require 'request_store'
require 'active_model_cachers/active_record/cacher'
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
        ActiveRecord::Cacher.define_cacher_at(attr.klass, attr.column || :self, [service_klass])
        return service_klass, (query.parameters.size == 1)
      end

      def create(cache_key, query)
        @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)

          class << klass
            def instance(id)
              hash = (RequestStore.store[self] ||= {})
              return hash[id] ||= new(id)
            end

            def clean_at(id)
              instance(id).clean_cache
            end
          end

          klass.send(:define_method, :cache_key){ @id ? "#{cache_key}_#{@id}" : cache_key }
          klass.send(:define_method, :get_without_cache){ @id ? query.call(@id) : query.call }
          next klass
        }[]
      end

      private

      def get_cache_key(attr)
        class_name, column = case
                             when attr.collection?  ; [attr.klass, attr.column]
                             when attr.association? ; [attr.class_name, nil]
                             else                   ; [attr.klass, attr.column]
                             end
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        return "active_model_cachers_#{class_name}"
      end
    end
  end
end
