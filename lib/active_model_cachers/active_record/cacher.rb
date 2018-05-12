# frozen_string_literal: true
module ActiveModelCachers
  module ActiveRecord
    class Cacher
      @defined_map = {}

      class << self
        def define_cacher_method(attr, service_klasses)
          method = attr.column || :self
          cacher_klass = get_cacher_klass(attr.klass)
          cacher_klass.attributes << method
          cacher_klass.send(:define_method, method){ exec_by(attr, service_klasses, :get) }
          cacher_klass.send(:define_method, "peek_#{method}"){ exec_by(attr, service_klasses, :peek) }
        end

        def get_cacher_klass(klass)
          @defined_map[klass] ||= create_cacher_klass_at(klass)
        end

        private

        def create_cacher_klass_at(target)
          cacher_klass = Class.new(self)
          cacher_klass.define_singleton_method(:attributes){ @attributes ||= [] }
          target.define_singleton_method(:cacher_at){|id| cacher_klass.new(id: id) }
          target.define_singleton_method(:cacher){ cacher_klass.new }
          target.send(:define_method, :cacher){ cacher_klass.new(model: self) }
          return cacher_klass
        end
      end

      def initialize(id: nil, model: nil)
        @id = (model ? model.id : nil) || id
        @model = model
      end

      private

      def exec_by(attr, service_klasses, method)
        if @model and attr.association?
          if attr.has_one?
            data = @model.send(attr.column).try(:id)
          else
            data = @model.send(attr.foreign_key)
            service_klasses = [service_klasses.last]
          end
        end
        data ||= @id
        service_klasses.all?{|s| (data = s.instance(data).send(method, binding: @model)) != nil }
        return data
      end
    end
  end
end
