module CartoDB
  module Model
    module AttributeMethods
      module Setters
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def table_name=(name)
            @table_name = name
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

        def method_missing(name, *args, &block)
          if args.count == 1 && block.nil? && name.to_s.ends_with?('=') && column_names.include?(name[0..-2].to_s)
            attributes[name[0..-2].to_sym] = args.first
          else
            super
          end
        end

      end
    end
  end
end
