## Fake rails for testing Rails.cache
class Rails
  class Cache
    def initialize
      @cache = {}
    end

    def read(key)
      return nil if not exist?(key)
      return @cache[key][:data]
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
  end

  def self.cache
    @@cache ||= Cache.new
  end
end
