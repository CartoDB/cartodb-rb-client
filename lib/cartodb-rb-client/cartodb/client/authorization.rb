require 'oauth/request_proxy/typhoeus_request'

module CartoDB
  module Client
    module Authorization

      def signed_request(request_uri, arguments)
        arguments[:disable_ssl_peer_verification] = true

        request = Typhoeus::Request.new(request_uri, arguments)

        request.headers.merge!({"Authorization" => oauth_helper(request, request_uri).header})

        request
      end
      private :signed_request

      def access_token
        return @access_token if @access_token

        @access_token ||= if CartoDB::Settings['oauth_access_token'] && CartoDB::Settings['oauth_access_token_secret']
          OAuth::AccessToken.new(oauth_consumer, CartoDB::Settings['oauth_access_token'], CartoDB::Settings['oauth_access_token_secret'])
        elsif CartoDB::Settings['username'] && CartoDB::Settings['password']
          access_token_url = oauth_consumer.access_token_url

          request = Typhoeus::Request.new(access_token_url,
            :method => :post,
            :params => {:x_auth_mode => :client_auth, :x_auth_username => CartoDB::Settings['username'], :x_auth_password => CartoDB::Settings['password']}
          )

          helper = OAuth::Client::Helper.new(request, {:consumer => oauth_consumer, :request_uri => access_token_url})

          request.headers.merge!({"Authorization" => helper.header})

          @hydra.queue request
          @hydra.run

          values = request.response.body.split('&').inject({}) { |h,v| h[v.split("=")[0]] = v.split("=")[1]; h }

          OAuth::AccessToken.new(oauth_consumer, values["oauth_token"], values["oauth_token_secret"])
        else
          nil
        end
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
