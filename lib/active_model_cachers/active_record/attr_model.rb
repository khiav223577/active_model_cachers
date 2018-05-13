# frozen_string_literal: true
module ActiveModelCachers
  module ActiveRecord
    class AttrModel
      attr_reader :klass, :column, :reflect

      def initialize(klass, column, primary_key: nil)
        @klass = klass
        @column = column
        @primary_key = primary_key
        @reflect = klass.reflect_on_association(column)
      end

      def association?
        return (@reflect != nil)
      end

      def class_name
        return if not association?
        return @reflect.class_name
      end

      def join_table
        return nil if @reflect == nil
        options = @reflect.options
        return options[:through] if options[:through]
        return (options[:join_table] || @reflect.send(:derive_join_table)) if @reflect.macro == :has_and_belongs_to_many
        return nil
      end

      def belongs_to?
        return false if not association?
        return @reflect.belongs_to?
      end

      def has_one?
        return false if not association?
        #return @reflect.has_one? # Rails 3 doesn't have this method
        return false if @reflect.collection?
        return false if @reflect.belongs_to?
        return true
      end

      def primary_key
        return @primary_key if @primary_key
        return if not association?
        return (@reflect.belongs_to? ? @reflect.klass : @reflect.active_record).primary_key
      end

      def foreign_key(reverse: false)
        return if not association?
        # key may be symbol if specify foreign_key in association options
        return @reflect.chain.last.foreign_key.to_s if reverse and join_table
        return (@reflect.belongs_to? == reverse ? primary_key : @reflect.foreign_key).to_s
      end

      def single_association?
        return false if not association?
        return !collection?
      end

      def collection?
        return false if not association?
        return @reflect.collection?
      end

      def query_model(binding, id)
        return query_self(binding, id) if @column == nil
        return query_association(binding, id) if association?
        return query_attribute(binding, id)
      end

      private

      def query_self(binding, id)
        return binding if binding.is_a?(::ActiveRecord::Base)
        return @klass.find_by(primary_key => id)
      end

      def query_attribute(binding, id)
        return binding.send(@column) if binding.is_a?(::ActiveRecord::Base) and binding.has_attribute?(@column)
        return @klass.where(id: id).limit(1).pluck(@column).first
      end

      def query_association(binding, id)
        return binding.association(@column).load_target if binding.is_a?(::ActiveRecord::Base)
        id = @reflect.active_record.where(id: id).limit(1).pluck(foreign_key).first if foreign_key != 'id'
        if @reflect.collection?
          return id ? @reflect.klass.where(@reflect.foreign_key => id).to_a : []
        else
          return id ? @reflect.klass.find_by(primary_key => id) : nil
        end
      end
    end
  end
end
