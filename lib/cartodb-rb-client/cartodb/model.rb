require 'active_support/core_ext/string'

module CartoDB
  class Model
    attr_reader :table, :columns, :attributes

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
      @@cartodb_table = nil
      @@table_name    = nil
      @attributes     = attributes
      update_cartodb_schema
    end

    class << self

      def create(attributes = {})
        model = self.new attributes
        model.save
        model
      end

      def all
        records = connection.records(table_name) || []
        if records.any? && records.rows
          records.rows.map{|r| self.new(r)}
        else
          []
        end
      end

      def where(attributes = nil, *rest)
        return all if attributes.nil? || (attributes.is_a?(Hash) && attributes.empty?) || (attributes.is_a?(Integer) && attributes <= 0)

        if attributes.is_a?(Integer) || (attributes.length == 1 && (attributes[:cartodb_id] || attributes[:id]))
          row_id = attributes.is_a?(Integer) ? attributes : (attributes[:cartodb_id] || attributes[:id])
          return self.new(connection.row(table_name, row_id))
        end

        columns = cartodb_table.schema.map{|c| {:name => c[0], :type => c[1]}}

        select = "SELECT #{columns.map{|c| c[:name]}.join(', ')}"
        from = "FROM #{table_name}"
        where = filters = nil

        case attributes
        when Hash
          filters = attributes.to_a.map{|i| "#{table_name}.#{i.first} = #{i.last}"}.join(' AND ')
        when String
          filters = attributes
          values  = rest
          filters = filters.gsub(/[\?]/){|r| values.shift}
        end

        where = "WHERE #{filters}" if filters

        results = connection.query "#{select} #{from} #{where}"

        if results && results.rows
          results.rows.map{|r| self.new(r)}
        else
          []
        end
      end

      def find(id)
        where(id)
      end

      def count
        begin
          results = connection.query "SELECT COUNT(CARTODB_ID) FROM #{table_name}"
          results.rows.first[:count]
        rescue Exception => e
          0
        end
      end

      def count=(ammount)
        @@count = ammount
      end

      def connection
        CartoDB::Connection
      end

      def table_name
        @@table_name ||= self.name.tableize
      end

      def table_name=(name)
        @@table_name = name
      end

      def cartodb_table
        @@cartodb_table ||= connection.table table_name
      end

      def cartodb_table=(table)
        @@cartodb_table = table
      end

      def columns
        @@columns
      end

      def columns=(columns)
        @@columns = columns
      end

      def field(name, options = {:type => String})
        @@columns ||= []
        column = {:name => name.to_s}
        column[:type] = CARTODB_TYPES[options[:type]] || 'string'
        @@columns << column
      end
      private :field

    end

    def connection
      self.class.connection
    end

    def table_name
      self.class.table_name
    end

    def count
      self.class.count
    end

    def count=(ammount)
      self.class.count= ammount
    end

    def cartodb_table_exists?
      begin
        cartodb_table && cartodb_table[:id] > 0 && cartodb_table.name.eql?(table_name)
      rescue CartoDB::Client::Error => e
        e.status_code != 404
      end
    end

    def cartodb_table
      self.class.cartodb_table
    end

    def cartodb_table=(table)
      self.class.cartodb_table = table
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
        update_row
      end
    end

    def new_record?
      cartodb_id.nil? || cartodb_id <= 0
    end

    def create_row
      # only the columns defined in the model are valid to create
      row = attributes.symbolize_keys.reject{|key,value| INVALID_COLUMNS.include?(key)}.select{|key,value| column_names.include?(key.to_s) }
      record_count = count
      inserted_record = connection.insert_row table_name, row
      @@count = record_count + 1
      self.cartodb_id = inserted_record.id
    end
    private :create_row

    def update_row
      row = attributes.select{|key,value| column_names.include?(key.to_s) }
      connection.update_row table_name, cartodb_id, row
    end
    private :update_row

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
        connection.add_column table_name, column[:name], column[:type]
      end

      self.cartodb_table = nil
      read_metadata self.cartodb_table
    end
    private :create_missing_columns

  end

end