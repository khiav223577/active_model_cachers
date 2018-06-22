module ActiveModelCachers
  module ActiveRecord
    module QueryHelper
      class << self
        def get_attribute(model, column)
          return model.send(column) if model.has_attribute?(column)
          return model.class.where(id: model.id).limit(1).pluck(column).first
        end
      end
    end
  end
end
