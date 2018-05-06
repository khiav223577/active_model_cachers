# frozen_string_literal: true
require 'active_support/dependencies'

module ActiveModelCachers::HookDepdenencies
  def onload(const_name, &block)
    const = const_name if not const_name.is_a?(String)
    if const or Module.const_defined?(const_name)
      (const || const_name.constantize).instance_exec(&block)
    else
      load_hooks[const_name].push(block)
    end
  end

  def load_hooks
    @load_hooks ||= Hash.new{|h, k| h[k] = [] }
  end

  def new_constants_in(*)
    new_constants = super.each{|s| load_hooks[s].each{|hook| s.constantize.instance_exec(&hook) } }
    return new_constants
  end
end

ActiveSupport::Dependencies.send(:extend, ActiveModelCachers::HookDepdenencies)
