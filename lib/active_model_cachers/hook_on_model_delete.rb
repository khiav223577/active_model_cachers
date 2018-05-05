require 'active_record'

module ActiveModelCachers::HookOnModelDelete
  def on_delete(&callback)
    delete_hooks << callback
  end

  def delete_hooks
    @delete_hooks ||= []
  end

  def clear_delete_hooks
    @delete_hooks = []
  end

  def delete(id)
    delete_hooks.each{|s| s.call(id) }
    super
  end
end

ActiveRecord::Base.send(:extend, ActiveModelCachers::HookOnModelDelete)
