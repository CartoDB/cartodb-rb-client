module CartoDB
  module API

    def create_table(table_name = nil, schema = nil)
      request = cartodb_request 'tables', :post, :params => {:name => table_name} do |response|
        created_table = Utils.parse_json(response)
        table_id      = created_table.id if created_table

        if table_id
          if schema
            schema.each do |column|
              cartodb_request "tables/#{table_id}/update_schema", :put, :params => { :what => "add", :column  => column }
            end
            execute_queue
          end
        end

        return created_table
      end

      execute_queue

      request.handled_response
    end

    def add_column(table_id, column_name, column_type)
      cartodb_request "tables/#{table_id}/update_schema",
                      :put,
                      :params => {
                        :what => "add",
                        :column  => {
                          :name => column_name,
                          :type => column_type
                        }
                      }

      execute_queue
    end

    def drop_column(table_id, column_name)
      cartodb_request "tables/#{table_id}/update_schema",
                      :put,
                      :params => {
                        :what => "drop",
                        :column  => {
                          :name => column_name
                        }
                      }

      execute_queue
    end

    def change_column(table_id, old_column_name, new_column_name, column_type)
      cartodb_request "tables/#{table_id}/update_schema",
                      :put,
                      :params => {
                        :what => "modify",
                        :column  => {
                          :old_name => old_column_name,
                          :new_name => new_column_name,
                          :type => column_type
                        }
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

    def table(id_or_name)
      found_table = nil
      case
      when id_or_name.is_a?(String)
        table_name = id_or_name
        found_table = tables.select{|table| table.name.eql? table_name}.first

        found_table = found_table ? table(found_table.id) : nil
      when id_or_name.is_a?(Integer)
        table_id = id_or_name
        request = cartodb_request "tables/#{table_id}" do |response|
          return Utils.parse_json(response)
        end

        execute_queue

        found_table = request.handled_response
      end
      found_table
    end

    def drop_table(table_id)
      cartodb_request "tables/#{table_id}", :delete

      execute_queue
    end

    def insert_row(table_id, row)
      cartodb_request "tables/#{table_id}/rows", :post, :params => row

      execute_queue
    end

    def update_row(table_id, row_id, row)
      cartodb_request "tables/#{table_id}/rows/#{row_id}", :put, :params => row

      execute_queue
    end

    def delete_row(table_id, row_id)
      cartodb_request "tables/#{table_id}/rows/#{row_id}", :delete

      execute_queue
    end

    def query(query)
      request = cartodb_request "tables/query", :params => {:sql => query} do |response|
        return Utils.parse_json(response)
      end

      execute_queue

      request.handled_response
    end

  end
end