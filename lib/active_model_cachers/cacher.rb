module ActiveModelCachers
  class Cacher
    @defined_map = {}

    def self.define_cacher_at(klass)
      @defined_map[klass] ||= ->{
        cacher = new
        klass.define_singleton_method(:cacher){ cacher }
        next (@defined_map[klass] = cacher )
      }[]
    end

    def initialize
    end

    def at(id)
      @id = id
      return self
    end
  end
end
