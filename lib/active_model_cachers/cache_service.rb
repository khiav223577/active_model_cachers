# frozen_string_literal: true
require 'active_model_cachers/nil_object'
require 'active_model_cachers/false_object'

module ActiveModelCachers
  class CacheService
    class << self
      attr_accessor :cache_key
      attr_accessor :query

      def instance(id)
        hash = (RequestStore.store[self] ||= {})
        return hash[id] ||= new(id)
      end

      def clean_at(id)
        instance(id).clean_cache
      end
    end

    def initialize(id)
      @id = id
    end

    def get
      @cached_data ||= fetch_from_cache
      return cache_to_raw_data(@cached_data)
    end

    def peek
      @cached_data ||= get_from_cache
      return cache_to_raw_data(@cached_data)
    end

    def clean_cache
      @cached_data = nil
      Rails.cache.delete(cache_key)
    end

    private

    def cache_key
      key = self.class.cache_key
      return @id ? "#{key}_#{@id}" : key
    end

    def get_without_cache
      query = self.class.query
      return @id ? query.call(@id) : query.call
    end

    def raw_to_cache_data(raw)
      return NilObject if raw == nil
      return FalseObject if raw == false
      return raw
    end

    def cache_to_raw_data(cached_data)
      return nil if cached_data == NilObject
      return false if cached_data == FalseObject
      return cached_data
    end

    def get_from_cache
      ActiveModelCachers.config.store.read(cache_key)
    end

    def fetch_from_cache
      ActiveModelCachers.config.store.fetch(cache_key, expires_in: 30.minutes) do
        raw_to_cache_data(get_without_cache)
      end
    end
  end
end
