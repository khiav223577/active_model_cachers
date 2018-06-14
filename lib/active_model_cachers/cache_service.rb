# frozen_string_literal: true
require 'active_model_cachers/nil_object'
require 'active_model_cachers/false_object'
require 'active_model_cachers/column_value_cache'

module ActiveModelCachers
  class CacheService
    class << self
      attr_accessor :cache_key
      attr_accessor :query_mapping

      def instance(id)
        hash = (RequestStore.store[self] ||= {})
        return hash[id] ||= new(id)
      end

      def clean_at(id)
        instance(id).clean_cache
      end

      @@column_value_cache = ActiveModelCachers::ColumnValueCache.new
      def define_callback_for_cleaning_cache(class_name, column, foreign_key, with_id, on: nil)
        return if @callbacks_defined
        @callbacks_defined = true

        clean = ->(id){ clean_at(with_id ? id : nil) }
        clean_ids = []
        fire_on = Array(on) if on

        ActiveRecord::Extension.global_callbacks.instance_exec do
          on_nullify(class_name) do |nullified_column, get_ids|
            get_ids.call.each{|s| clean.call(s) } if nullified_column == column
          end

          after_touch(class_name) do
            clean.call(send(foreign_key))
          end

          after_commit(class_name) do # TODO: on
            next if fire_on and not transaction_include_any_action?(fire_on)
            changed = column ? previous_changes.key?(column) : previous_changes.present?
            clean.call(send(foreign_key)) if changed || destroyed?
          end

          pre_before_delete(class_name) do |id, model|
            clean_ids << @@column_value_cache.add(self, class_name, id, foreign_key, model)
          end

          before_delete(class_name) do |_, model|
            clean_ids.each{|s| clean.call(s.call) }
            clean_ids = []
          end

          after_delete(class_name) do
            @@column_value_cache.clean_cache
          end
        end
      end
    end

    # ----------------------------------------------------------------
    # ● instance methods
    # ----------------------------------------------------------------
    def initialize(id)
      @id = id
    end

    def get(binding: nil, attr: nil)
      @cached_data ||= fetch_from_cache(binding: binding, attr: attr)
      return cache_to_raw_data(@cached_data)
    end

    def peek(binding: nil, attr: nil)
      @cached_data ||= get_from_cache
      return cache_to_raw_data(@cached_data)
    end

    def clean_cache(binding: nil, attr: nil)
      @cached_data = nil
      Rails.cache.delete(cache_key)
      return nil
    end

    private

    def cache_key
      key = self.class.cache_key
      return @id ? "#{key}_#{@id}" : key
    end

    def get_query(binding, attr)
      self.class.query_mapping[attr] || self.class.query_mapping.values.first
    end

    def get_without_cache(binding, attr)
      query = get_query(binding, attr)
      return binding ? binding.instance_exec(@id, &query) : query.call(@id) if @id and query.parameters.size == 1
      return binding ? binding.instance_exec(&query) : query.call
    end

    def raw_to_cache_data(raw)
      return NilObject if raw == nil
      return FalseObject if raw == false
      clean_ar_cache(raw.is_a?(Array) ? raw : [raw])
      return raw_without_singleton_methods(raw)
    end

    def cache_to_raw_data(cached_data)
      return nil if cached_data == NilObject
      return false if cached_data == FalseObject
      return cached_data
    end

    def get_from_cache
      ActiveModelCachers.config.store.read(cache_key)
    end

    def fetch_from_cache(binding: nil, attr: nil)
      ActiveModelCachers.config.store.fetch(cache_key, expires_in: 30.minutes) do
        raw_to_cache_data(get_without_cache(binding, attr))
      end
    end

    def clean_ar_cache(models)
      return if not models.first.is_a?(::ActiveRecord::Base)
      models.each_with_index do |model, index|
        model.send(:clear_aggregation_cache)
        model.send(:clear_association_cache)
      end
    end

    def raw_without_singleton_methods(raw)
      return raw if raw.singleton_methods.empty?
      return raw.class.find_by(id: raw.id) if raw.is_a?(::ActiveRecord::Base) # cannot marshal singleton, so load a new record instead.
      return raw # not sure what to do with other cases
    end
  end
end
