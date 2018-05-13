# frozen_string_literal: true
module ActiveModelCachers
  module ActiveRecord
    class Cacher
      @defined_map = {}

      class << self
        def define_cacher_method(attr, primary_key, service_klasses)
          method = attr.column || (primary_key == :id ? :self : :"self_by_#{primary_key}")
          cacher_klass = get_cacher_klass(attr.klass)
          cacher_klass.attributes << method
          cacher_klass.send(:define_method, method){ exec_by(attr, primary_key, service_klasses, :get) }
          cacher_klass.send(:define_method, "peek_#{method}"){ exec_by(attr, primary_key, service_klasses, :peek) }
          cacher_klass.send(:define_method, "clean_#{method}"){ exec_by(attr, primary_key, service_klasses, :clean_cache) }
        end

        def get_cacher_klass(klass)
          @defined_map[klass] ||= create_cacher_klass_at(klass)
        end

        private

        def create_cacher_klass_at(target)
          cacher_klass = Class.new(self)
          cacher_klass.define_singleton_method(:attributes){ @attributes ||= [] }
          cacher_klass.send(:define_method, 'peek'){|column| send("peek_#{column}") }
          cacher_klass.send(:define_method, 'clean'){|column| send("clean_#{column}") }

          target.define_singleton_method(:cacher_at){|id| cacher_klass.new(id: id) }
          target.define_singleton_method(:cacher){ cacher_klass.new }
          target.send(:define_method, :cacher){ cacher_klass.new(model: self) }
          return cacher_klass
        end
      end

      def initialize(id: nil, model: nil)
        @id = id
        @model = model
      end

      private

      def exec_by(attr, primary_key, service_klasses, method)
        bindings = [@model]
        if @model and attr.association?
          association = @model.association(attr.column)
          case
          when attr.has_one?
            data = association.load_target.try(primary_key)
          when attr.belongs_to?
            bindings << association.load_target if association.loaded? and method != :clean_cache # no need to load binding when just cleaning cache
          end
        end
        data ||= (@model ? @model.send(primary_key) : nil) || @id
        service_klasses.each_with_index do |service_klass, index|
          data = service_klass.instance(data).send(method, binding: bindings[index])
          return if data == nil
        end
        return data
      end
    end
  end
end
