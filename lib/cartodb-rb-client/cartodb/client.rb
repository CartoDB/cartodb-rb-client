require 'cartodb-rb-client/cartodb/client/api'
require 'cartodb-rb-client/cartodb/client/authorization'
require 'cartodb-rb-client/cartodb/client/requests'

module CartoDB
  class Client
    include CartoDB::API
    include CartoDB::Authorization
    include CartoDB::Requests

    def initialize(init_settings = nil)
      raise Exception.new 'CartoDB settings not found' if init_settings.nil?
      @settings = {}
      @settings[:host]         = init_settings['host']
      @settings[:oauth_key]    = init_settings['oauth_key']
      @settings[:oauth_secret] = init_settings['oauth_secret']
      @settings[:api_key]      = init_settings['api_key']

      @hydra = Typhoeus::Hydra.new(:max_concurrency => 200)
    end

    def settings
      @settings
    end
    private :settings

  end
end