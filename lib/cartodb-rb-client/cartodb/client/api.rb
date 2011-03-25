module CartoDB
  module Client
    module API

      VERSION = 'v1'.freeze

      def create_table(table_name = nil, schema = nil)
        request = cartodb_request 'tables', :post, :params => {:name => table_name} do |response|
          created_table = Utils.parse_json(response)
          table_name      = created_table.name if created_table

          if table_name
            if schema
              schema.each do |column|
                cartodb_request "tables/#{table_name}/columns", :post, :params => column
              end
              execute_queue
            end
          end

          return table table_name
        end

        execute_queue

        request.handled_response
      end

      def add_column(table_name, column_name, column_type)
        cartodb_request "tables/#{table_name}/columns",
                        :post,
                        :params => {
                          :name => column_name,
                          :type => column_type
                        }

        execute_queue
      end

      def drop_column(table_name, column_name)
        cartodb_request "tables/#{table_name}/columns/#{column_name}",
                        :delete

        execute_queue
      end

      def change_column(table_name, old_column_name, new_column_name, column_type)
        cartodb_request "tables/#{table_name}/columns/#{old_column_name}",
                        :put,
                        :params => {
                          :new_name => new_column_name,
                          :type => column_type
                        }

        execute_queue
      end

      def tables
        request = cartodb_request 'tables' do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def table(table_name)
        request = cartodb_request "tables/#{table_name}" do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def drop_table(table_name)
        cartodb_request "tables/#{table_name}", :delete

        execute_queue
      end

      def row(table_name, row_id)
        cartodb_request "tables/#{table_name}/records/#{row_id}" do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def insert_row(table_name, row)
        cartodb_request "tables/#{table_name}/records", :post, :params => row do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def update_row(table_name, row_id, row)
        cartodb_request "tables/#{table_name}/records/#{row_id}", :put, :params => row

        execute_queue
      end

      def delete_row(table_name, row_id)
        cartodb_request "tables/#{table_name}/records/#{row_id}", :delete

        execute_queue
      end

      def records(table_name)
        request = cartodb_request "tables/#{table_name}/records" do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def query(query)
        request = cartodb_request '', :params => {:sql => query} do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

    end
  end
end