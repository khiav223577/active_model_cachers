# frozen_string_literal: true
require 'active_model_cachers/active_record/global_callbacks'
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

        loaded = false
        class_name, *infos = get_expire_infos(attr, expire_by, foreign_key)
        set_klass_to_mapping(attr, class_name) do
          next if !loaded
          cache_at(column, query, expire_by: expire_by, on: on, foreign_key: foreign_key, primary_key: primary_key)
        end
        loaded = true

        query ||= ->(id){ attr.query_model(self, id) }
        service_klass = CacheServiceFactory.create_for_active_model(attr, query)
        Cacher.define_cacher_method(attr, attr.primary_key || :id, [service_klass])

        if class_name
          with_id = (expire_by.is_a?(Symbol) || query.parameters.size == 1)
          service_klass.define_callback_for_cleaning_cache(class_name, *infos, with_id, on: on)
        end

        return service_klass
      end

      def has_cacher?(column = nil)
        attr = AttrModel.new(self, column)
        return CacheServiceFactory.has_cacher?(attr)
      end

      private

      def set_klass_to_mapping(attr, class_name)
        ActiveSupport::Dependencies.onload(class_name || self.to_s) do
          yield if CacheServiceFactory.set_klass_to_mapping(attr, self)
        end
      end

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

      @global_callbacks = nil
      def self.global_callbacks
        if @global_callbacks == nil
          global_callbacks = @global_callbacks = GlobalCallbacks.new
          ::ActiveRecord::Base.instance_exec do
            after_commit ->{
              global_callbacks.after_commit1.exec(self, self.class)
              global_callbacks.after_commit2.exec(self, self.class)
            }
            after_touch ->{
              global_callbacks.after_touch1.exec(self, self.class)
              global_callbacks.after_touch2.exec(self, self.class)
            }
          end
        end
        return @global_callbacks
      end
    end
  end
end

if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4')
  require 'active_model_cachers/active_record/patch_rails_3'
end
