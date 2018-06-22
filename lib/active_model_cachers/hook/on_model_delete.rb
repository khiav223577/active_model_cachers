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
      def delete(id, model = nil)
        ActiveModelCachers::ActiveRecord::Extension.global_callbacks.before_delete1.exec(self, self, id, model)
        ActiveModelCachers::ActiveRecord::Extension.global_callbacks.before_delete2.exec(self, self, id, model)

        result = super(id)

        ActiveModelCachers::ActiveRecord::Extension.global_callbacks.after_delete.exec(self, self, id, model)
        return result
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveModelCachers::Hook::OnModelDelete::InstanceMethods)
ActiveRecord::Base.send(:extend, ActiveModelCachers::Hook::OnModelDelete::ClassMethods)
