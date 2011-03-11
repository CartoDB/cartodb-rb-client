module CartoDB
  class Client
    include Typhoeus

    attr_accessor :settings

    def initialize(settings = nil)
      raise Exception.new 'CartoDB settings not found' if settings.nil?
      self.settings = {}
      self.settings[:host]         = settings['host']
      self.settings[:key]          = settings['api_key']
      self.settings[:oauth_key]    = settings['oauth_key']
      self.settings[:oauth_secret] = settings['oauth_secret']
      @hydra        = Typhoeus::Hydra.new(:max_concurrency => 200)
    end

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
                      },
                      :headers => {'Content-Length' => '0'}

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
                      },
                      :headers => {'Content-Length' => '0'}

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
                      },
                      :headers => {'Content-Length' => '0'}

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

        found_table = table(found_table.id)
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
      request = cartodb_request "tables/query", :params => {:query => query} do |response|
        return Utils.parse_json(response)
      end

      execute_queue

      request.handled_response
    end

##################
# private methods

    def cartodb_request(uri, method = :get, arguments = {:params => {}}, &block)
      params = arguments[:params]
      if method.is_a? Hash
        params = method[:params]
        method = :get
      end

      params[:api_key] = settings[:key]

      format = 'json'
      url    = generate_url uri
      headers =  {'Accept' => MIME::Types['application/json']}
      headers = headers.merge(arguments[:headers]) if arguments[:headers]

      request = Request.new(url,
        :method        => method,
        :params        => params,
        :headers       => headers,
        :verbose       => false
      )

      request.on_complete do |response|
        if response.success?
          yield(response) if block_given?
        else
          puts response.code
          puts response.body
          raise CartoError.new url, method, response
        end
      end

      enqueue request
      request
    end
    private :cartodb_request

    def enqueue(request)
      @hydra.queue request
    end
    private :enqueue

    def execute_queue
      @hydra.run
    end
    private :execute_queue

    def generate_url(uri)
      uri = URI.parse("#{settings[:host]}/api/json/#{uri}")
      "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
    end
    private :generate_url
  end
end