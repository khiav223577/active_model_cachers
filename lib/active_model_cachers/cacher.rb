module ActiveModelCachers
  class Cacher
    @defined_map = {}

    class << self
      def define_cacher_at(klass, method, service_klass)
        cacher_klass = (@defined_map[klass] ||= create_cacher_klass_at(klass))
        cacher_klass.send(:define_method, method){ service_klass.instance(@id).get }
      end

      private

      def create_cacher_klass_at(target)
        cacher_klass = Class.new(self)
        target.define_singleton_method(:cacher_at){|id| cacher_klass.new(id) }
        return cacher_klass
      end
    end

    def initialize(id)
      @id = id
    end
  end
end
