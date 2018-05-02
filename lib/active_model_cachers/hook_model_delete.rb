require 'active_record'

class ActiveRecord::Base
  class << self
    def on_delete(&callback)
      delete_hooks << callback
    end

    def clear_delete_hooks
      self.delete_hooks = []
    end

    alias_method :delete_without_hook_by_active_record_cacher, :delete if not method_defined?(:delete_without_hook_by_active_record_cacher)
    def delete(id)
      delete_hooks.each{|s| s.call(id) }
      delete_without_hook_by_active_record_cacher(id)
    end
  end

  mattr_accessor :delete_hooks
  clear_delete_hooks
end
