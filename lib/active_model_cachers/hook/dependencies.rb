# frozen_string_literal: true
require 'active_support/dependencies'

module ActiveModelCachers::Hook
  module Depdenencies
    def onload(const_name, times: 1, &block)
      const = const_name if not const_name.is_a?(String)
      if const or Module.const_defined?(const_name)
        (const || const_name.constantize).instance_exec(&block)
      else
        load_hooks[const_name].push(block: block, times: times)
      end
    end

    def load_hooks
      @load_hooks ||= Hash.new{|h, k| h[k] = [] }
    end

    def new_constants_in(*)
      new_constants = super.each do |const_name|
        hooks = load_hooks[const_name]
        need_compact = false
        hooks.each_with_index do |hook, idx|
          if (hook[:times] -= 1) < 0
            hooks[idx] = nil
            need_compact = true
            next
          end
          const_name.constantize.instance_exec(&hook[:block])
        end
        hooks.compact! if need_compact
      end
      return new_constants
    end
  end
end

ActiveSupport::Dependencies.send(:extend, ActiveModelCachers::Hook::Depdenencies)
