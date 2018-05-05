module ActiveModelCachers
  module ActiveRecord
    module Extension
      def cache_self
        cache_at(nil, expire_by: self.to_s)
      end

      def cache_at(column, query = nil, expire_by: nil, on: nil, foreign_key: :id)
        service_klass, with_id = ActiveModelCachers::CacheServiceFactory.create_for_active_model(self, column, &query)

        expire_by ||= reflect_on_association(column).try(:class_name) || "#{self}##{column}"
        class_name, column = expire_by.split('#', 2)

        define_callback_for_cleaning_cache(class_name, column, foreign_key, on: on) do |id| 
          service_klass.clean_at(with_id ? id : nil)
        end
      end

      private

      def define_callback_for_cleaning_cache(class_name, column, foreign_key, on: nil, &clean)
        ActiveSupport::Dependencies.onload(class_name) do
          on_delete do |id|
            clean.call(id)
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
