require 'active_model_cachers'

## Fake rails for testing Rails.cache
class Rails
  class Cache
    def initialize
      clear
    end

    def clear
      @cache = {}
    end

    def read(key)
      return nil if not exist?(key)
      return @cache[key][:data]
    end

    def delete(key)
      @cache.delete(key)
    end

    def exist?(key)
      data = @cache[key]
      return nil if data == nil
      return nil if data[:expired_at] <= Time.now
      return data[:data]
    end

    def write(key, val, options = {})
      @cache[key] ||= { data: val, expired_at: Time.now + 30.minutes }
      return val
    end

    def fetch(key, options = {}, &block)
      read(key) || write(key, block.call)
    end

    def all_data
      result = {}
      @cache.keys.select{|k| exist?(k) }.each{|k| result[k] = read(k) }
      return result
    end
  end

  def self.cache
    @@cache ||= Cache.new
  end
end

ActiveModelCachers.config do |config|
  config.store = Rails.cache
end

