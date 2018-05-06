# frozen_string_literal: true
if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4')
  class << ActiveRecord::Base
    alias_method :create_with_protection, :create
    def create(args = nil) # mass-assign protected attributes `id` In Rails 3
      return args.map{|s| create(s) } if args.is_a?(Array)
      return create_with_protection(args, without_protection: true)
    end
  end
end
