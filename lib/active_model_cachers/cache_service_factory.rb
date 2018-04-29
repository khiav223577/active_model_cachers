require 'request_store'
require 'active_model_cachers/cache_service'

module ActiveModelCachers
  class CacheServiceFactory
    @key_class_mapping = {}

    class << self
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
