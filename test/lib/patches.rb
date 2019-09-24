# frozen_string_literal: true

class ActiveRecord::Base
  if not public_method_defined?(:update)
    alias origin_rails_update update
    def update(*args) # For Rails 3
      args.any? ? update_attributes(*args) : origin_rails_update
    end
  end
end
