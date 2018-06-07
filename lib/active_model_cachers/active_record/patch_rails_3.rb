# frozen_string_literal: true
module ActiveModelCachers
  module ActiveRecord
    module Extension
      # define #find_by for Rails 3
      def find_by(*args)
        where(*args).order('').first
      end
    end
  end
end

module ActiveRecord
  module Associations
    # = Active Record Associations
    #
    # This is the root class of all associations ('+ Foo' signifies an included module Foo):
    #
    #   Association
    #     SingularAssociation
    #       HasOneAssociation
    #         HasOneThroughAssociation + ThroughAssociation
    #       BelongsToAssociation
    #         BelongsToPolymorphicAssociation
    #     CollectionAssociation
    #       HasAndBelongsToManyAssociation
    #       HasManyAssociation
    #         HasManyThroughAssociation + ThroughAssociation
    class Association #:nodoc:
      alias_method :scope, :scoped
    end
  end
end

class ActiveModelCachers::ColumnValueCache
  def pluck_columns(object, relation, columns)
    object.connection.select_all(relation.select(columns)).map(&:values)
  end
end
