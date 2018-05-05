module ActiveModelCachers
  module ActiveRecord
    module Extension
      # define #find_by for Rails 3
      def find_by(*args)
        where(*args).order('').first
      end

      # after_commit in Rails 3 cannot specify multiple :on
      # EX: 
      #   after_commit ->{ ... }, on: [:create, :destroy]
      #
      # Should rewrite it as:
      #   after_commit ->{ ... }, on: :create
      #   after_commit ->{ ... }, on: :destroy

      def after_commit(*args, &block) # mass-assign protected attributes `id` In Rails 3
        if args.last.is_a?(Hash)
          if (on = args.last[:on]).is_a?(Array)
            return on.each{|s| after_commit(*[*args[0...-1], { **args[-1], on: s }], &block) }
          end
        end
        super
      end
    end
  end
end
