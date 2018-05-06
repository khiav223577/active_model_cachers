# frozen_string_literal: true
require 'active_record'
require 'active_record/associations/has_many_association'
require 'active_model_cachers/hook_on_model_delete'

module ActiveModelCachers::HookAssociations
  def delete_count(method, scope)
    if method == :delete_all
      # TODO:
    else # nullify
      call_hooks(scope)
    end
    super
  end

  def delete_records(records, method)
    if method == :destroy
      # TODO:
    else
      call_hooks(self.scope.where(reflection.klass.primary_key => records))
    end
    super
  end

  private

  def call_hooks(scope)
    return if (hooks = reflection.klass.nullify_hooks_at(reflection.foreign_key)).blank?
    ids = scope.pluck(:id)
    hooks.each{|s| s.call(ids) }
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:prepend, ActiveModelCachers::HookAssociations)
