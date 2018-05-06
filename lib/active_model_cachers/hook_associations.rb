require 'active_record'
require 'active_model_cachers/hook_on_model_delete'

module ActiveModelCachers::HookAssociations
  def delete_count(method, scope)
    if method == :delete_all
      # TODO:
    else # nullify
      hooks = reflection.klass.nullify_hooks_at(reflection.foreign_key)
      if hooks.present?
        ids = scope.pluck(:id)
        hooks.each{|s| s.call(ids) }
      end
    end
    super
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:prepend, ActiveModelCachers::HookAssociations)
