module ActiveModelCachers
  module ActiveRecord
    class AttrModel
      attr_reader :klass, :column, :reflect

      def initialize(klass, column)
        @klass = klass
        @column = column
        @reflect = klass.reflect_on_association(column)
      end

      def association?
        return (@reflect != nil)
      end

      def class_name
        return if not association?
        return @reflect.class_name
      end

      def belongs_to?
        return false if not association?
        return @reflect.belongs_to?
      end

      def primary_key
        return if not association?
        return (@reflect.belongs_to? ? @reflect.klass : @reflect.active_record).primary_key
      end

      def foreign_key(reverse: false)
        return if not association?
        # key may be symbol if specify foreign_key in association options
        return @reflect.chain.last.foreign_key.to_s if reverse
        return (@reflect.belongs_to? == reverse ? primary_key : @reflect.foreign_key).to_s
      end

      def query_model(id)
        return @klass.find_by(id: id) if @column == nil # Cache self
        return @klass.where(id: id).limit(1).pluck(@column).first if not association? # Cache attributes
        id = @reflect.active_record.where(id: id).limit(1).pluck(foreign_key).first if foreign_key != 'id'
        return id ? @reflect.klass.find_by(primary_key => id) : nil
      end
    end
  end
end
