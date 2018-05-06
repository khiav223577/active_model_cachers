# frozen_string_literal: true
module ActiveModelCachers
  class Cacher
    @defined_map = {}

    class << self
      def define_cacher_at(klass, method, service_klasses)
        cacher_klass = get_cacher_klass(klass)
        cacher_klass.attributes << method
        cacher_klass.send(:define_method, method){ exec_by(service_klasses, :get) }
        cacher_klass.send(:define_method, "peek_#{method}"){ exec_by(service_klasses, :peek) }
      end

      def get_cacher_klass(klass)
        @defined_map[klass] ||= create_cacher_klass_at(klass)
      end

      private

      def create_cacher_klass_at(target)
        cacher_klass = Class.new(self)
        cacher_klass.define_singleton_method(:attributes){ @attributes ||= [] }
        target.define_singleton_method(:cacher_at){|id| cacher_klass.new(id) }
        target.define_singleton_method(:cacher){ cacher_klass.new }
        return cacher_klass
      end
    end

    def initialize(id = nil)
      @id = id
    end

    private

    def exec_by(service_klasses, method)
      data = @id
      service_klasses.all?{|s| (data = s.instance(data).send(method)) != nil }
      return data
    end
  end
end
