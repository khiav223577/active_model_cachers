require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    @key_class_mapping = {}

    class << self
      def create_for_active_model(model_klass, column, &query)
        model_klass.instance_exec do
          if column
            reflect = reflect_on_association(column)
            if reflect
              query ||= ->(id){ (reflect.belongs_to? ? reflect.active_record : reflect.klass).find_by(id: id) }
              cache_key = "cacher_key_of_#{reflect.class_name}"
            else
              query ||= ->(id){ where(id: id).limit(1).pluck(column).first }
              cache_key = "cacher_key_of_#{self}_at_#{column}"
            end
          else
            query ||= ->(id){ find_by(id: id) }
            cache_key = "cacher_key_of_#{self}"
          end
          service_klass = ActiveModelCachers::CacheServiceFactory.create(cache_key, &query)
          ActiveModelCachers::Cacher.define_cacher_at(self, column || :self, service_klass)
          return service_klass
        end
      end

      def create(cache_key, &query)
        @key_class_mapping[cache_key] ||= ->{
          klass = Class.new(CacheService)
          
          class << klass
            def instance(id)
              hash = (RequestStore.store[self] ||= {})
              return hash[id] ||= new(id)
            end

            def [](id)
              instance(id)
            end
          end

          klass.send(:define_method, :cache_key){ "#{cache_key}_#{@id}" }
          klass.send(:define_method, :get_without_cache){ query.call(@id) }
          next klass
        }[]
      end
    end
  end
end
