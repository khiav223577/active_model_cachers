require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    class << self
      def create(reflect, cache_key, &query)
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
        klass.send(:define_method, :get_without_cache) do 
          if reflect
            target = (reflect.belongs_to? ? reflect.active_record : reflect.klass)
            next target.find_by(id: @id)
          else
            next query.call(@id)
          end
        end
        return klass
      end
    end
  end
end
