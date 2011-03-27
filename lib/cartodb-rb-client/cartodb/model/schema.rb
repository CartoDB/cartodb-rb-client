module CartoDB
  module Model
    module Schema

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include CartoDB::Model::Constants

        def field(name, options = {:type => String})
          @columns ||= []
          @columns << {
            :name => name.to_s,
            :type =>  CARTODB_TYPES[options[:type]] || 'string'
          }
        end
        private :field

      end

      def cartodb_table_exists?
        begin
          cartodb_table && cartodb_table[:id] > 0 && cartodb_table.name.eql?(table_name)
        rescue CartoDB::Client::Error => e
          e.status_code != 404
        end
      end

      def update_cartodb_schema
        table = nil
        if cartodb_table_exists?
          table = cartodb_table
        else
          table = connection.create_table table_name, self.class.columns
        end
        read_metadata table
        create_missing_columns
      end
      private :update_cartodb_schema

      def read_metadata(table)
        extract_columns table
      end
      private :read_metadata

      def extract_columns(table)
        @columns = table.schema.map{|c| {:name => c[0], :type => c[1]}}
      end
      private :extract_columns

      def create_missing_columns
        missing_columns = self.class.columns - @columns
        return unless missing_columns && missing_columns.any?

        missing_columns.each do |column|
          connection.add_column table_name, column[:name], column[:type]
        end

        self.cartodb_table = nil
        read_metadata self.cartodb_table
      end
      private :create_missing_columns

    end
  end
end
