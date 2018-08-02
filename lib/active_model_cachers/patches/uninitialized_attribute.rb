if defined?(ActiveRecord::Attribute)
  class ActiveRecord::Attribute
    class Uninitialized < self
      def forgetting_assignment
        dup
      end
    end
  end
end
