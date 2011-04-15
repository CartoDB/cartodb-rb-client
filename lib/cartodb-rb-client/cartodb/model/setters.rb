module CartoDB
  module Model
    module Setters
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def cartodb_table_name(table_name)
          @table_name = table_name
        end

        def cartodb_table=(table)
          @cartodb_table = table
        end

        def columns=(columns)
          @columns = columns
        end

      end

      def cartodb_table=(table)
        self.class.cartodb_table = table
      end

      def attributes=(attributes)
        @attributes = prepare_geo_attributes(attributes)
      end

      # def method_missing(name, *args, &block)
      #   if args.count == 1 && block.nil? && name.to_s.ends_with?('=') && column_names.include?(name.to_s[0..-2])
      #     attributes[name.to_s[0..-2].to_sym] = args.first
      #   else
      #     super
      #   end
      # end

    end
  end
end