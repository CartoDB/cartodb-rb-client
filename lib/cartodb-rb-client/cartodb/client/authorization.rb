require 'oauth/request_proxy/typhoeus_request'

module CartoDB
  module Client
    module Authorization

      def signed_request(request_uri, arguments)
        arguments[:disable_ssl_peer_verification] = true
        if settings['api_key']
          arguments[:params] = {}.merge!(arguments[:params])
          arguments[:params][:api_key] = settings['api_key']

          request = Typhoeus::Request.new(request_uri, arguments)
          return request
        end

        request = Typhoeus::Request.new(request_uri, arguments)

        request.headers.merge!({"Authorization" => oauth_helper(request, request_uri).header})

        request.params[:oauth_token] = oauth_params[:token].params['oauth_token']

        request
      end
      private :signed_request

      def access_token
        return @access_token if @access_token

        # Set a new request_token
        request_token = oauth_consumer.get_request_token

        response = Typhoeus::Request.get(request_token.authorize_url,
          'authorize'                    => '1',
          'oauth_token'                  => request_token.token,
          :disable_ssl_peer_verification => !settings['ssl_peer_verification'],
          :verbose                       => settings['debug']
        )

        url = URI.parse(response.headers_hash['Location'])

        # get the verifier from the url
        verifier = url.query.split('&').select{ |q| q =~ /^oauth_verifier/}.first.split('=')[1]

        # Get an access token with the verifier
        @access_token = request_token.get_access_token(:oauth_verifier => verifier)
      end
      private :access_token

      def oauth_params
        {:consumer => oauth_consumer, :token => access_token}
      end
      private :oauth_params

      def oauth_consumer
        @oauth_consumer ||= OAuth::Consumer.new(CartoDB::Settings['oauth_key'], CartoDB::Settings['oauth_secret'], :site => CartoDB::Settings['host'])
      end
      private :oauth_consumer

      def oauth_helper(request, request_uri)
        OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => request_uri))
      end
      private :oauth_helper
    end
  end
end
