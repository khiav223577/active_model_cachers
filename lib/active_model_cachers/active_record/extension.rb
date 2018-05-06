# frozen_string_literal: true
require 'active_model_cachers/active_record/attr_model'
require 'active_model_cachers/active_record/cacher'
require 'active_model_cachers/hook/dependencies'
require 'active_model_cachers/hook/associations'
require 'active_model_cachers/hook/on_model_delete'

module ActiveModelCachers
  module ActiveRecord
    module Extension
      def cache_self
        cache_at(nil, expire_by: self.name)
      end

      def cache_at(column, query = nil, expire_by: nil, on: nil, foreign_key: nil)
        attr = AttrModel.new(self, column)
        return cache_belongs_to(attr) if attr.belongs_to?

        query ||= ->(id){ attr.query_model(id) }
        service_klass, with_id = CacheServiceFactory.create_for_active_model(attr, query)

        expire_by ||= get_expire_by(attr)
        class_name, column = expire_by.split('#', 2)
        foreign_key ||= attr.foreign_key(reverse: true) || :id

        define_callback_for_cleaning_cache(class_name, column, foreign_key, on: on) do |id|
          service_klass.clean_at(with_id ? id : nil)
        end
        return service_klass
      end

      def has_cacher?(column = nil)
        attr = AttrModel.new(self, column)
        return CacheServiceFactory.has_cacher?(attr)
      end

      private

      def get_expire_by(attr)
        return "#{self}##{attr.column}" if not attr.association?
        return "#{attr.class_name}##{attr.foreign_key(reverse: true)}" if attr.collection?
        return attr.class_name
      end

      def cache_belongs_to(attr)
        service_klasses = [cache_at(attr.foreign_key)]
        Cacher.define_cacher_at(self, attr.column, service_klasses)
        ActiveSupport::Dependencies.onload(attr.class_name) do
          service_klasses << cache_self
        end
      end

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
