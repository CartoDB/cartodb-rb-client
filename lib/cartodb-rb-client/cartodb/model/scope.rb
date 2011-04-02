module CartoDB
  module Model
    class Scope
      extend Forwardable

      def_delegators :@model, :connection, :table_name, :cartodb_table

      def initialize(model)
        @model   = model
        @records = nil
      end

      def to_a
        @records ||= begin
          select = build_select
          from   = build_from
          where  = build_where

          results = connection.query "#{select} #{from} #{where}"

          if results && results.rows
            results.rows.map{|r| @model.new(r)}
          else
            []
          end
        rescue Exception => e
          []
        end

      end
      alias all to_a

      def length
        to_a.length
      end
      alias size length

      def where(attributes = nil, *rest)
        @records = nil
        return all if attributes.nil? || (attributes.is_a?(Hash) && attributes.empty?) || (attributes.is_a?(Integer) && attributes <= 0)

        if attributes.is_a?(Integer) || (attributes.length == 1 && (attributes[:cartodb_id] || attributes[:id]))
          row_id = attributes.is_a?(Integer) ? attributes : (attributes[:cartodb_id] || attributes[:id])
          return @model.new(connection.row(table_name, row_id))
        end

        create_filters(attributes, rest)

        self
      end

      def method_missing(method, *args, &block)
        if Array.method_defined?(method)
          to_a.send(method, *args, &block)
        elsif Base.method_defined?(method)
          puts method
          @model.send(method, *args, &block)
        else
          super
        end
      end
      protected :method_missing

      def filters
        @filters ||= []
      end
      private :filters

      def build_select
        columns = cartodb_table.schema.map{|c| {:name => c[0], :type => c[1]}}
        select = "SELECT #{columns.map{|c| c[:name]}.join(', ')}"
      end
      private :build_select

      def build_from
        from = "FROM #{table_name}"
      end
      private :build_from

      def build_where
        where = "WHERE #{filters.join(' AND ')}" if filters && filters.any?
      end
      private :build_where

      def create_filters(attributes, values)
        case attributes
        when Hash
          filters << attributes.to_a.map{|i| "#{table_name}.#{i.first} = #{i.last}"}.join(' AND ')
        when String
          values = values.flatten
          filters << attributes.gsub(/[\?]/){|r| values.shift}
        end
      end
      private :create_filters

    end
  end
end