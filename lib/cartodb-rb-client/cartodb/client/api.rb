module CartoDB
  module Client
    module API

      VERSION      = 'v1'.freeze

      def create_table(table_name = nil, schema_or_file = nil)
        schema = schema_or_file if schema_or_file && schema_or_file.is_a?(Array)
        file   = schema_or_file if schema_or_file && schema_or_file.is_a?(File)

        params = {:name => table_name}
        params[:file] = file if file
        request = cartodb_request 'tables', :post, :params => params do |response|
          created_table = Utils.parse_json(response)
          table_name      = created_table.name if created_table

          if table_name
            if schema && schema.is_a?(Array)
              schema.each do |column|
                cartodb_request "tables/#{table_name}/columns", :post, :params => column
              end
              execute_queue
              return table table_name
            else
              return created_table
            end
          end
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

      def records(table_name, options = {})
        request = cartodb_request "tables/#{table_name}/records", :params => options.slice(:rows_per_page, :page) do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

      def query(query, options = {})
        params = {:sql => query}

        if options && options.any?
          params[:page]          = options[:page]          if options[:page]
          params[:rows_per_page] = options[:rows_per_page] if options[:rows_per_page]
        end

        request = cartodb_request '', :post, :params => params do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        request.handled_response
      end

    end
  end
end
