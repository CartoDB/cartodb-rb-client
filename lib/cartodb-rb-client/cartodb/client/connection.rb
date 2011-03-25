module CartoDB
  module Client
    class Connection
      include OAuth::RequestProxy::Typhoeus
      include CartoDB::Client::API
      include CartoDB::Client::Authorization
      include CartoDB::Client::Requests
      include CartoDB::Client::Utils

      def initialize
        raise Exception.new 'CartoDB settings not found' if CartoDB::Settings.nil?

        @hydra = Typhoeus::Hydra.new(:max_concurrency => 200)

        # @cache = {}
        # @hydra.cache_setter do |request|
        #   @cache[request.cache_key] = request.response
        # end
        #
        # @hydra.cache_getter do |request|
        #   @cache[request.cache_key]
        # end
      end

      def settings
        CartoDB::Settings || {}
      end
      private :settings

    end
  end
end