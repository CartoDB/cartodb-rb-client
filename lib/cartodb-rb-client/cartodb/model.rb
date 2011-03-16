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

      create_schema
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
        @table ||= connection.table @table_name
        table && table.id > 0 && table.name.eql?(@table_name)
      rescue CartoDB::CartoError => e
        e.status_code != 404
      end
    end

    def create_schema
      unless cartodb_table_exists?
        created_table = connection.create_table table_name, self.class.columns
        read_metadata created_table
      end
    end
    private :create_schema

    def read_metadata(table)
      extract_columns table
    end
    private :read_metadata

    def extract_columns(table)
      @columns = table.schema.map{|c| {:name => c[0], :type => c[1]}}
    end
    private :extract_columns

  end

end