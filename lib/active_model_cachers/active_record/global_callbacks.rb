module ActiveModelCachers
  module ActiveRecord
    class GlobalCallbacks
      def initialize
        @type_callbacks = {}
      end

      def after_touch(class_name = nil, &block)
        (@type_callbacks[:after_touch] ||= ClassCallbacks.new).tap do |s|
          s.add_callback(class_name, &block) if class_name
        end
      end
    end

    class ClassCallbacks
      def initialize
        @class_callbacks = Hash.new{|h, k| h[k] = [] }
      end

      def add_callback(class_name, &block)
        @class_callbacks[class_name] << block
      end

      def exec(model)
        @class_callbacks[model.class.name].each{|s| model.instance_exec(&s) }
      end
    end
  end
end
