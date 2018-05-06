require 'active_model_cachers/active_record/attr_model'

module ActiveModelCachers
  module ActiveRecord
    module Extension
      def cache_self
        cache_at(nil, expire_by: self.to_s)
      end

      def cache_at(column, query = nil, expire_by: nil, on: nil, foreign_key: :id)
        attr = AttrModel.new(self, column)
        service_klass, with_id = ActiveModelCachers::CacheServiceFactory.create_for_active_model(attr, &query)

        expire_by ||= attr.association? ? attr.class_name : "#{self}##{column}"
        class_name, column = expire_by.split('#', 2)

        define_callback_for_cleaning_cache(class_name, column, foreign_key, on: on) do |id|
          service_klass.clean_at(with_id ? id : nil)
        end
      end

      def has_cacher?(column = nil)
        attr = AttrModel.new(self, column)
        return ActiveModelCachers::CacheServiceFactory.has_cacher?(attr)
      end

      private

      def get_column_value_from_id(id, column)
        return id if column == :id
        model = cacher_at(id).peek_self if has_cacher?
        return model.send(column) if model
        return where(id: id).limit(1).pluck(column).first
      end

      def define_callback_for_cleaning_cache(class_name, column, foreign_key, on: nil, &clean)
        ActiveSupport::Dependencies.onload(class_name) do
          ids = []
          before_delete do |id|
            ids << get_column_value_from_id(id, foreign_key)
          end

          after_delete do
            ids.each{|s| clean.call(s) }
            ids = []
          end

          after_commit ->{
            changed = column ? previous_changes.key?(column) : previous_changes.present?
            clean.call(send(foreign_key)) if changed || destroyed?
          }, on: on
        end
      end
    end
  end
end

if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4')
  require 'active_model_cachers/active_record/patch_rails_3'
end
