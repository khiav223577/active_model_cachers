module ActiveModelCachers
  class CacheService
    def initialize(id)
      @id = id
    end

    def get
      @cached_data ||= get_from_cache
    end

    def clean_cache
      # @cached_data = nil
      Rails.cache.delete(cache_key)
    end

    private

    def cache_key
      fail 'not implement'
    end

    def get_without_cache
      fail 'not implement'
    end

    def get_from_cache
      ActiveModelCachers.config.store.fetch(cache_key, expires_in: 30.minutes){ get_without_cache }
    end
  end
end
