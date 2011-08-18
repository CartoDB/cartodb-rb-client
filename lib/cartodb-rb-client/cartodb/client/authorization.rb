require 'oauth/request_proxy/typhoeus_request'

module CartoDB
  module Client
    module Authorization

      def signed_request(request_uri, arguments)
        arguments[:disable_ssl_peer_verification] = true

        request = Typhoeus::Request.new(request_uri, params_hash_values_as_json(arguments))

        request.headers.merge!({"Authorization" => oauth_helper(request, request_uri).header})

        request
      end
      private :signed_request

      def access_token
        @access_token ||= OAuth::AccessToken.new(oauth_consumer, CartoDB::Settings['oauth_access_token'], CartoDB::Settings['oauth_access_token_secret'])
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

      def params_hash_values_as_json(arguments)
        params = arguments[:params]
        params.each do |key,value|
          case value
          when Hash
            params[key] = value.to_json
          end
        end
        arguments[:params] = params
        arguments
      end
      private :params_hash_values_as_json
    end
  end
end
