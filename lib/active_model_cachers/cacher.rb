module ActiveModelCachers
  class Cacher
    @defined_map = {}

    def self.define_cachers_at(klass)
      return if @defined_map[klass]
      klass.define_singleton_method(:cachers){ new }
      @defined_map[klass] = true 
    end

    def initialize(id = nil)
      @id = id
    end

    def [](id)
      Cacher.new(id)
    end
  end
end
