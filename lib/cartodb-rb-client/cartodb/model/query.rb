module CartoDB
  module Model
    module Query

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
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

          select = build_select
          from   = build_from
          where  = build_where(attributes, rest)

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
          @count = ammount
        end

        def build_select
          columns = cartodb_table.schema.map{|c| {:name => c[0], :type => c[1]}}
          select = "SELECT #{columns.map{|c| c[:name]}.join(', ')}"
        end
        private :build_select

        def build_from
          from = "FROM #{table_name}"
        end
        private :build_from

        def build_where(attributes, values)
          where = filters = nil

          case attributes
          when Hash
            filters = attributes.to_a.map{|i| "#{table_name}.#{i.first} = #{i.last}"}.join(' AND ')
          when String
            filters = attributes
            filters = filters.gsub(/[\?]/){|r| values.shift}
          end

          where = "WHERE #{filters}" if filters
        end

      end

      def count
        self.class.count
      end

      def count=(ammount)
        self.class.count= ammount
      end

    end
  end
end
