require 'cartodb-rb-client/cartodb/client/api'
require 'cartodb-rb-client/cartodb/client/authorization'
require 'cartodb-rb-client/cartodb/client/requests'

module CartoDB
  class Client
    include OAuth::RequestProxy::Typhoeus
    include CartoDB::API
    include CartoDB::Authorization
    include CartoDB::Requests

    def initialize
      raise Exception.new 'CartoDB settings not found' if CartoDB::Settings.nil?

      @settings = {}
      @settings[:host]         = CartoDB::Settings['host']
      @settings[:oauth_key]    = CartoDB::Settings['oauth_key']
      @settings[:oauth_secret] = CartoDB::Settings['oauth_secret']
      @settings[:api_key]      = CartoDB::Settings['api_key']

      @hydra = Typhoeus::Hydra.new(:max_concurrency => 200)
    end

    def settings
      @settings
    end
    private :settings

  end
end