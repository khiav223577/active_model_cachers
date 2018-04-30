module ActiveModelCachers
  class Cacher
    @defined_map = {}

    def self.define_cacher_at(klass)
      @defined_map[klass] ||= ->{
        cacher = new
        klass.define_singleton_method(:cacher){|id| cacher.with_id(id) }
        next (@defined_map[klass] = cacher )
      }[]
    end

    def initialize
    end

    def with_id(id)
      @id = id
      return self
    end
  end
end
