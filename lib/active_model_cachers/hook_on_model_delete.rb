# frozen_string_literal: true
require 'active_record'

module ActiveModelCachers::HookOnModelDelete
  def before_delete(&callback)
    before_delete_hooks << callback
  end

  def after_delete(&callback)
    after_delete_hooks << callback
  end

  def before_delete_hooks
    @before_delete_hooks ||= []
  end

  def after_delete_hooks
    @after_delete_hooks ||= []
  end

  def delete(id)
    before_delete_hooks.each{|s| s.call(id) }
    result = super
    after_delete_hooks.each{|s| s.call(id) }
    return result
  end

  def nullify_hooks_at(column)
    @nullify_hooks ||= Hash.new{|h, k| h[k] = [] }
    return @nullify_hooks[column]
  end

  def on_nullify(column, &callback)
    nullify_hooks_at(column) << callback
  end
end

ActiveRecord::Base.send(:extend, ActiveModelCachers::HookOnModelDelete)
