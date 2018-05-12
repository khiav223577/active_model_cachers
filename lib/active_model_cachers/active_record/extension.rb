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
        Cacher.define_cacher_method(attr, [service_klass])

        expire_attr = get_expire_attr(expire_by, attr)
        expire_by = nil if expire_by.is_a?(Symbol)
        expire_by ||= get_expire_by_from(expire_attr)

        class_name, column = expire_by.split('#', 2)
        # foreign_key ||= 'user_id' if attr.collection?
        foreign_key ||= expire_attr.foreign_key(reverse: true) || 'id'

        define_callback_for_cleaning_cache(class_name, column, foreign_key.to_s, on: on) do |id|
          service_klass.clean_at(with_id ? id : nil)
        end
        return service_klass
      end

      def has_cacher?(column = nil)
        attr = AttrModel.new(self, column)
        return CacheServiceFactory.has_cacher?(attr)
      end

      private

      def get_expire_attr(expire_by, attr)
        if expire_by.is_a?(Symbol)
          expire_attr = AttrModel.new(self, expire_by)
          raise "#{expire_by} is not an association" if not expire_attr.association?
          return expire_attr
        else
          return attr
        end
      end

      def get_expire_by_from(attr)
        return "#{self}##{attr.column}" if not attr.association?
        return attr.class_name
      end

      def cache_belongs_to(attr)
        service_klasses = [cache_at(attr.foreign_key)]
        Cacher.define_cacher_method(attr, service_klasses)
        ActiveSupport::Dependencies.onload(attr.class_name) do
          service_klasses << cache_self
        end
      end

      def get_column_value_from_id(id, column, model)
        return id if column == 'id'
        model ||= cacher_at(id).peek_self if has_cacher?
        return model.send(column) if model
        return where(id: id).limit(1).pluck(column).first
      end

      @@column_value_cache = Hash.new{|h, k| h[k] = {}}
      def define_callback_for_cleaning_cache(class_name, column, foreign_key, on: nil, &clean)
        ActiveSupport::Dependencies.onload(class_name) do
          clean_ids = []
          cache = @@column_value_cache[class_name]
          before_delete do |id, model|
            clean_ids << (cache[[id, foreign_key]] ||= get_column_value_from_id(id, foreign_key, model))
          end

          after_delete do |_, model|
            clean_ids.each{|s| clean.call(s) }
            clean_ids = []
            cache.clear
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
