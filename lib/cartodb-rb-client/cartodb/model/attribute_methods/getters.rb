module CartoDB
  module Model
    module AttributeMethods
      module Getters
        attr_reader :table, :columns, :attributes

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def connection
            CartoDB::Connection
          end

          def table_name
            @table_name ||= self.name.tableize
          end

          def cartodb_table
            @cartodb_table ||= connection.table table_name
          end

          def columns
            @columns
          end

        end

        def connection
          self.class.connection
        end

        def table_name
          self.class.table_name
        end

        def cartodb_table
          self.class.cartodb_table
        end

        def method_missing(name, *args, &block)
          if args.empty? && block.nil? && column_names.include?(name.to_s)
            attributes[name]
          else
            super
          end
        end

        def column_names
          columns.map{|column| column[:name]}
        end
        private :column_names

      end
    end
  end
end