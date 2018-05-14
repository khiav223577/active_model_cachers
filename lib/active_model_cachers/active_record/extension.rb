# frozen_string_literal: true
require 'active_model_cachers/column_value_cache'
require 'active_model_cachers/active_record/attr_model'
require 'active_model_cachers/active_record/cacher'
require 'active_model_cachers/hook/dependencies'
require 'active_model_cachers/hook/associations'
require 'active_model_cachers/hook/on_model_delete'

module ActiveModelCachers
  module ActiveRecord
    module Extension
      def cache_self(by: :id)
        cache_at(nil, expire_by: self.name, primary_key: by, foreign_key: by)
      end

      def cache_at(column, query = nil, expire_by: nil, on: nil, foreign_key: nil, primary_key: nil)
        attr = AttrModel.new(self, column, foreign_key: foreign_key, primary_key: primary_key)
        return cache_belongs_to(attr) if attr.belongs_to?

        query ||= ->(id){ attr.query_model(self, id) }
        service_klass = CacheServiceFactory.create_for_active_model(attr, query)
        Cacher.define_cacher_method(attr, attr.primary_key || :id, [service_klass])

        with_id = true if expire_by.is_a?(Symbol) or query.parameters.size == 1
        expire_class, expire_column, foreign_key = get_expire_infos(attr, expire_by, foreign_key)
        if expire_class
          define_callback_for_cleaning_cache(expire_class, expire_column, foreign_key, on: on) do |id|
            service_klass.clean_at(with_id ? id : nil)
          end
        end
        return service_klass
      end

      def has_cacher?(column = nil)
        attr = AttrModel.new(self, column)
        return CacheServiceFactory.has_cacher?(attr)
      end

      private

      def get_expire_infos(attr, expire_by, foreign_key)
        if expire_by.is_a?(Symbol)
          expire_attr = get_association_attr(expire_by)
          expire_by = get_expire_by_from(expire_attr)
        else
          expire_attr = attr
          expire_by ||= get_expire_by_from(expire_attr)
        end
        return if expire_by == nil

        class_name, column = expire_by.split('#', 2)
        foreign_key ||= expire_attr.foreign_key(reverse: true) || 'id'

        return class_name, column, foreign_key.to_s
      end

      def get_association_attr(column)
        attr = AttrModel.new(self, column)
        raise "#{column} is not an association" if not attr.association?
        return attr
      end

      def get_expire_by_from(attr)
        return attr.class_name if attr.association?
        return "#{self}##{attr.column}" if column_names.include?(attr.column.to_s)
      end

      def cache_belongs_to(attr)
        service_klasses = [cache_at(attr.foreign_key)]
        Cacher.define_cacher_method(attr, attr.primary_key, service_klasses)
        ActiveSupport::Dependencies.onload(attr.class_name) do
          service_klasses << cache_self
        end
      end

      @@column_value_cache = ActiveModelCachers::ColumnValueCache.new
      def define_callback_for_cleaning_cache(class_name, column, foreign_key, on: nil, &clean)
        ActiveSupport::Dependencies.onload(class_name) do
          clean_ids = []

          prepend_before_delete do |id, model|
            clean_ids << @@column_value_cache.add(self, class_name, id, foreign_key, model)
          end

          before_delete do |_, model|
            clean_ids.each{|s| clean.call(s.call) }
            clean_ids = []
          end

          after_delete do
            @@column_value_cache.clean_cache()
          end

          on_nullify(column){|ids| ids.each{|s| clean.call(s) }}

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
