class ActiveModelCachers::ColumnValueCache
  class Value
    def initialize(column_value_cache)
      @column_value_cache = column_value_cache
    end

    def get_id
      @column_value_cache
    end
  end

  def initialize
    @cache = Hash.new{|h, k| h[k] = {} }
  end

  def clear_at(class_name)
    @cache[class_name].clear
  end


  def add(object, class_name, id, foreign_key, model)
    value = (@cache[class_name][[id, foreign_key]] ||= do_query(object, id, foreign_key, model))
    return Value.new(value)
  end

  private

  def do_query(object, id, column, model)
    return id if column == 'id'
    model ||= object.cacher_at(id).peek_self if object.has_cacher?
    return model.send(column) if model
    return object.where(id: id).limit(1).pluck(column).first
  end
end
