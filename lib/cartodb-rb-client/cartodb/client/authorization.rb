module CartoDB
  module Authorization
    include Typhoeus

    def signed_request(url, arguments)
      if @user
        uri = arguments[:uri]
        request = Request.new(url, arguments)

        oauth_params = {:consumer => oauth_consumer, :token => @user.access_token}
        oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => uri))

        request.headers.merge!({'Authorization' => oauth_helper.header})
      elsif settings[:api_key]
        arguments[:params] = {} unless arguments[:params]
        arguments[:params][:api_key] = settings[:api_key]

        request = Request.new(url, arguments)
      end
      request
    end
    private :signed_request

    def oauth_params
      return {} unless @user
      {:consumer => oauth_consumer, :token => @user.access_token}
    end
    private :oauth_params

    def oauth_consumer
      @oauth_consumer ||= OAuth::Consumer.new(OAuthConfig['token'], OAuthConfig['secret'])
    end
    private :oauth_consumer
  end
end
