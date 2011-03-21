require 'active_support/core_ext/string'

module CartoDB
  class Model
    attr_reader :connection, :table_name, :table, :columns

    CARTODB_TYPES = {
      String     => 'string',
      Integer    => 'number',
      Numeric    => 'number',
      Date       => 'date',
      DateTime   => 'date',
      TrueClass  => 'boolean',
      FalseClass => 'boolean'
    }

    def initialize()
      @connection = CartoDB::Client.new
      @table_name = self.class.name.tableize

      update_cartodb_schema
    end

    def self.columns
      @@columns
    end

    def self.field(name, options = {:type => String})
      @@columns ||= []
      column = {:name => name.to_s}
      column[:type] = CARTODB_TYPES[options[:type]] || 'string'
      @@columns << column
    end

    def cartodb_table_exists?
      begin
        cartodb_table && cartodb_table[:id] > 0 && cartodb_table.name.eql?(@table_name)
      rescue CartoDB::CartoError => e
        e.status_code != 404
      end
    end

    def cartodb_table
      @cartodb_table ||= connection.table @table_name
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
        connection.add_column @table_name, column[:name], column[:type]
      end
      @cartodb_table = nil
      read_metadata cartodb_table
    end
    private :create_missing_columns

  end

end