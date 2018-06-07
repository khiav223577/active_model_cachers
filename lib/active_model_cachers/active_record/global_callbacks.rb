module ActiveModelCachers
  module ActiveRecord
    class GlobalCallbacks
      def initialize
        @type_callbacks = {}
      end

      def pre_before_delete(class_name = nil, &block)
        define_callbacks(:pre_before_delete, class_name, &block)
      end

      def before_delete(class_name = nil, &block)
        define_callbacks(:before_delete, class_name, &block)
      end

      def after_delete(class_name = nil, &block)
        define_callbacks(:after_delete, class_name, &block)
      end

      def on_nullify(class_name = nil, &block)
        define_callbacks(:on_nullify, class_name, &block)
      end

      def after_commit(class_name = nil, &block)
        define_callbacks(:after_commit, class_name, &block)
      end

      def after_touch(class_name = nil, &block)
        define_callbacks(:after_touch, class_name, &block)
      end

      private

      def define_callbacks(type, class_name, &block)
        (@type_callbacks[type] ||= ClassCallbacks.new).tap do |s|
          s.add_callback(class_name, &block) if class_name
        end
      end
    end

    class ClassCallbacks
      def initialize
        @class_callbacks = Hash.new{|h, k| h[k] = [] }
      end

      def callbacks_at(class_name)
        @class_callbacks[class_name]
      end

      def add_callback(class_name, &block)
        callbacks_at(class_name) << block
      end

      def exec(scope, klass, *args)
        callbacks_at(klass.name).each{|s| scope.instance_exec(*args, &s) }
      end
    end
  end
end
