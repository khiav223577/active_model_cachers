require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    @key_class_mapping = {}

    class << self
      def create_for_active_model(klass, column, &query)
        reflect = klass.reflect_on_association(column)
        case
        when column == nil # Cache self
          query ||= ->(id){ klass.find_by(id: id) } 
          cache_key = get_cache_key(klass, column)
        when reflect       # Cache associations
          query ||= ->(id){ get_klass_from_reflect(reflect).find_by(id: id) }
          cache_key = get_cache_key(reflect.class_name, nil)
        else               # Cache attributes
          query ||= ->(id){ klass.where(id: id).limit(1).pluck(column).first }
          cache_key = get_cache_key(klass, column)
        end
        service_klass = create(cache_key, &query)
        ActiveModelCachers::Cacher.define_cacher_at(klass, column || :self, service_klass)
        return service_klass, (query.parameters.size == 1)
      end

      def create(cache_key, &query)
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

            def [](id)
              instance(id)
            end
          end

          klass.send(:define_method, :cache_key){ @id ? "#{cache_key}_#{@id}" : cache_key }
          klass.send(:define_method, :get_without_cache){ @id ? query.call(@id) : query.call }
          next klass
        }[]
      end

      private

      def get_klass_from_reflect(reflect)
        return reflect.active_record if reflect.belongs_to?
        return reflect.klass
      end

      def get_cache_key(class_name, column)
        return "active_model_cachers_#{class_name}_at_#{column}" if column
        return "active_model_cachers_#{class_name}"
      end
    end
  end
end
