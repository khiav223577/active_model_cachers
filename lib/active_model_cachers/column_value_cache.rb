class ActiveModelCachers::ColumnValueCache
  def initialize
    @cache1 = Hash.new{|h, k| h[k] = {} }
    @cache2 = Hash.new{|h, k| h[k] = {} }
  end

  def add(object, class_name, id, foreign_key, model)
    value = (@cache1[class_name][[id, foreign_key]] ||= get_id_from(object, id, foreign_key, model))
    return ->{ (value == :not_set ? query_value(object, class_name, id, foreign_key) : value)}
  end

  def query_value(object, class_name, id, foreign_key)
    cache = @cache2[class_name]
    if cache.empty?
      no_data_keys = @cache1[class_name].select{|k, v| v == :not_set }.keys
      ids = no_data_keys.map(&:first).uniq
      columns = ['id', *no_data_keys.map(&:second)].uniq
      pluck_columns(object, object.where(id: ids).limit(ids.size), columns).each do |columns_data|
        model_id = columns_data.first
        columns.each_with_index do |column, index|
          cache[[model_id, column]] = columns_data[index]
        end
      end
    end
    return cache[[id, foreign_key]]
  end

  def clean_cache
    @cache1.clear
    @cache2.clear
  end

  private

  def pluck_columns(_, relation, columns)
    relation.pluck(*columns)
  end

  def get_id_from(object, id, column, model)
    return id if column == 'id'
    model ||= object.cacher_at(id).peek_self if object.has_cacher?
    return model.send(column) if model
    return :not_set
  end
end
