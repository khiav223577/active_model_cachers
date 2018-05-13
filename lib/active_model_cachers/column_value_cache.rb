class ActiveModelCachers::ColumnValueCache
  def initialize
    @cache1 = Hash.new{|h, k| h[k] = {} }
    @cache2 = Hash.new{|h, k| h[k] = {} }
  end

  def clear_at(class_name)
    @cache1[class_name].clear
  end

  def add(object, class_name, id, foreign_key, model)
    @cache2[class_name].clear
    value = (@cache1[class_name][[id, foreign_key]] ||= get_id_from(object, id, foreign_key, model))
    return ->{ value }
  end

  private

  def get_id_from(object, id, column, model)
    return id if column == 'id'
    model ||= object.cacher_at(id).peek_self if object.has_cacher?
    return model.send(column) if model
    return object.where(id: id).limit(1).pluck(column).first
  end
end
