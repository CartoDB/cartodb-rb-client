module CartoDB
  module Client
    module Requests

      def cartodb_request(uri, method = :get, arguments = {:params => {}}, &block)
        params = arguments[:params]
        if method.is_a? Hash
          params = method[:params]
          method = :get
        end

        uri = "/#{CartoDB::Client::API::VERSION}/#{uri}"
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

    end
  end
end