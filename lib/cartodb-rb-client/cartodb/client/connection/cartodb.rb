module CartoDB
  module Client
    module Connection
      class CartoDBConnection
        include OAuth::RequestProxy::Typhoeus
        include CartoDB::Client::Authorization
        include CartoDB::Client::Utils

        VERSION = 'v1'.freeze

        def initialize(connection_settings)
          @hydra = Typhoeus::Hydra.new(:max_concurrency => 200)
        end

        def create_table(table_name = nil, schema_or_file = nil, the_geom_type = 'Point')
          schema = schema_or_file if schema_or_file && schema_or_file.is_a?(Array)
          file   = schema_or_file if schema_or_file && schema_or_file.is_a?(File)

          params = {:name => table_name}
          params[:file] = file if file
          params[:schema] = schema.map{|s| "#{s[:name]} #{s[:type]}"}.join(', ') if schema

          request = cartodb_request 'tables', :post, :params => params, :the_geom_type => the_geom_type do |response|
            return Utils.parse_json(response)
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

        def query(sql, options = {})
          sql = sql.strip if sql

          if sql.include?('*')
            table_name = sql.match(/select(.*)\s((\w+\.)?\*)(.*)from\s+(\w*)[^;]*;?/im)[5]
            schema = table(table_name).schema if table_name

            sql.gsub!(/^select(.*)\s((\w+\.)?\*)(.*)from/im) do |matches|
              %Q{SELECT #{$1.strip} #{schema.map{|c| "#{$3}#{c[0]}"}.join(', ')} #{$4.strip} FROM}
            end
          end

          if sql.include?('the_geom')
            sql.gsub!(/^select(.*)\s((\w+\.)?the_geom)(.*)from/im) do |matches|
              "SELECT #{$1.strip} ST_AsGeoJSON(#{$3}the_geom) as the_geom#{$4.strip} FROM"
            end
          end

          params = {:sql => sql}

          if options && options.any?
            params[:page]          = options[:page]          if options[:page]
            params[:rows_per_page] = options[:rows_per_page] if options[:rows_per_page]
          end

          request = cartodb_request '', :params => params do |response|
            return Utils.parse_json(response)
          end

          execute_queue

          request.handled_response
        end

        def cartodb_request(uri, method = :get, arguments = {:params => {}}, &block)
          params = arguments[:params]
          if method.is_a? Hash
            params = method[:params]
            method = :get
          end

          uri = "/api/#{VERSION}/#{uri}"
          url = generate_url uri

          headers                  = {}
          headers['Accept']        = MIME::Types['application/json']
          headers.merge!(arguments[:headers]) if arguments[:headers]

          request = signed_request(url,
            :method        => method,
            :headers       => headers,
            :params        => params,
            :cache_timeout => settings['cache_timeout'],
            :verbose       => settings['debug']
          )

          request.on_complete do |response|
            if response.success?
              yield(response) if block_given?
            else
              raise CartoDB::Client::Error.new url, method, response
            end
          end

          enqueue request
        end
        private :cartodb_request

        def enqueue(request)
          @hydra.queue request
          request
        end
        private :enqueue

        def execute_queue
          @hydra.run
        end
        private :execute_queue

        def generate_url(uri)
          uri = URI.parse("#{settings['host']}#{uri}")
          "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
        end
        private :generate_url

        def settings
          CartoDB::Settings || {}
        end
        private :settings

      end
    end
  end
end
