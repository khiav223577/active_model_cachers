# frozen_string_literal: true
module ActiveModelCachers
  module ActiveRecord
    class Cacher
      @defined_map = {}

      class << self
        def get_cacher_klass(klass)
          @defined_map[klass] ||= create_cacher_klass_at(klass)
        end

        def define_cacher_method(attr, primary_key, service_klasses)
          cacher_klass = get_cacher_klass(attr.klass)
          method = attr.column
          return cacher_klass.define_find_by(attr, primary_key, service_klasses) if method == nil
          cacher_klass.send(:define_methods, method, {
            method            => ->{ exec_by(attr, primary_key, service_klasses, :get) },
            "peek_#{method}"  => ->{ exec_by(attr, primary_key, service_klasses, :peek) },
            "clean_#{method}" => ->{ exec_by(attr, primary_key, service_klasses, :clean_cache) },
          })
        end

        def define_find_by(attr, primary_key, service_klasses)
          if @find_by_mapping == nil
            @find_by_mapping = {}
            define_methods(:find_by, {
              :find_by   => ->(args){ exec_find_by(args, :get) },
              :peek_by   => ->(args){ exec_find_by(args, :peek) },
              :clean_by  => ->(args){ exec_find_by(args, :clean_cache) },
            })
          end
          @find_by_mapping[primary_key] = [attr, service_klasses]
        end

        private

        def define_methods(attribute, methods_mapping)
          if attributes.include?(attribute)
            methods_mapping.keys.each{|s| undef_method(s) }
          else
            attributes << attribute
          end
          methods_mapping.each{|method, block| define_method(method, &block) }
        end

        def get_data_from_find_by_mapping(primary_key)
          return if @find_by_mapping == nil
          return @find_by_mapping[primary_key]
        end

        def create_cacher_klass_at(target)
          cacher_klass = Class.new(self)
          cacher_klass.instance_variable_set(:@find_by_mapping, nil) # to remove warning: instance variable @find_by_mapping not initialized
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

      def exec_find_by(args, method) # e.g. args = {course_id: xx}
        primary_key = args.keys.sort.first # Support only one key now.
        attr, service_klasses = self.class.send(:get_data_from_find_by_mapping, primary_key)
        return if service_klasses == nil
        return exec_by(attr, primary_key, service_klasses, method, data: args[primary_key])
      end

      def exec_by(attr, primary_key, service_klasses, method, data: nil)
        bindings = [@model]
        if @model and attr.association?
          if attr.belongs_to? and method != :clean_cache # no need to load binding when just cleaning cache
            association = @model.association(attr.column)
            bindings << association.load_target if association.loaded?
          end
        end
        data ||= (@model ? @model.send(primary_key) : nil) || @id
        service_klasses.each_with_index do |service_klass, index|
          data = service_klass.instance(data).send(method, binding: bindings[index], attr: attr)
          return if data == nil
        end
        return data
      end
    end
  end
end
