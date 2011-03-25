require 'active_support/core_ext/string'

module CartoDB
  class Model
    attr_reader :connection, :table_name, :table, :columns, :attributes

    CARTODB_TYPES = {
      String     => 'string',
      Integer    => 'number',
      Numeric    => 'number',
      Date       => 'date',
      DateTime   => 'date',
      TrueClass  => 'boolean',
      FalseClass => 'boolean'
    }.freeze

    INVALID_COLUMNS = [
      :cartodb_id,
      :id
    ].freeze

    def initialize(attributes = {})
      @connection = CartoDB::Client::Connection.new
      @table_name = self.class.name.tableize
      @attributes = attributes.symbolize_keys.reject{|key,value| INVALID_COLUMNS.include?(key)}

      update_cartodb_schema
      set_attributes
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
      rescue CartoDB::Client::Error => e
        e.status_code != 404
      end
    end

    def cartodb_table
      @cartodb_table ||= connection.table @table_name
    end

    def method_missing(name, *args, &block)
      if args.empty? && block.nil? && column_names.include?(name.to_s)
        attributes[name]
      elsif args.count == 1 && block.nil? && name.to_s.ends_with?('=') && column_names.include?(name[0..-2].to_s)
        attributes[name[0..-2].to_sym] = args.first
      else
        super
      end
    end

    def save
      if new_record?
        create_row
      else
      end
    end

    def new_record?
      cartodb_id.nil? || cartodb_id <= 0
    end

    def create_row
      # only the columns defined in the model are valid to create
      row = attributes.select{|key,value| column_names.include?(key.to_s) }
      inserted_record = connection.insert_row table_name, row
      self.cartodb_id = inserted_record.id
    end
    private :create_row

    def column_names
      columns.map{|column| column[:name]}
    end
    private :column_names

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

    def set_attributes

    end
    private :set_attributes

  end

end