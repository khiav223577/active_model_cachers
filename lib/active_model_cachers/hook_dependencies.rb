require 'active_support/dependencies'

module ActiveSupport #:nodoc:
  module Dependencies #:nodoc:
    class << self
      def onload(const_name, &block)
        const = const_name if not const_name.is_a?(String)
        if const or Module.const_defined?(const_name)
          (const || const_name.constantize).instance_exec(&block)
        else
          load_hooks[const_name].push(block)
        end
      end

      def clear_load_hooks
        self.load_hooks = Hash.new{|h, k| h[k] = [] }
      end

      alias_method :new_constants_in_without_onload_hook, :new_constants_in if not method_defined?(:new_constants_in_without_onload_hook)
      def new_constants_in(*descs, &block)
        new_constants = new_constants_in_without_onload_hook(*descs, &block)
        new_constants.each{|s| load_hooks[s].each{|hook| s.constantize.instance_exec(&hook) } }
        return new_constants
      end
    end

    mattr_accessor :load_hooks
    clear_load_hooks
  end
end
