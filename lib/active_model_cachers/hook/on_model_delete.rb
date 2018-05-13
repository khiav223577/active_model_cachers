# frozen_string_literal: true
require 'active_record'

module ActiveModelCachers::Hook
  module OnModelDelete
    module InstanceMethods
      def delete
        self.class.delete(id, self) if persisted?
        @destroyed = true
        freeze
      end
    end

    module ClassMethods
      def prepend_before_delete(&callback)
        before_delete_hooks.unshift(callback)
      end

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

      def delete(id, model = nil)
        before_delete_hooks.each{|s| s.call(id, model) }
        result = super(id)
        after_delete_hooks.each{|s| s.call(id, model) }
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
  end
end

ActiveRecord::Base.send(:include, ActiveModelCachers::Hook::OnModelDelete::InstanceMethods)
ActiveRecord::Base.send(:extend, ActiveModelCachers::Hook::OnModelDelete::ClassMethods)
