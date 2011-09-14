require 'warden'
require 'rails_warden'
require 'omniauth'
require 'multi_json'

require 'cartodb-rb-client/railties/omniauth_cartodb_authentication'
require 'cartodb-rb-client/railties/warden_strategies'

module CartoDB
  class Railtie < Rails::Railtie

    initializer "cartoDB_railtie.configure_rails_initialization" do |app|

      CartoDB::Init.start
      init_warden app
      init_omniaouth app

    end

      def init_omniaouth(rails_app)
        rails_app.middleware.use OmniAuth::Builder do
          host = oauth_key = oauth_secret = nil
          if CartoDB.const_defined?('Settings')
            host = CartoDB::Settings['host']
            oauth_key = CartoDB::Settings['oauth_key']
            oauth_secret = CartoDB::Settings['oauth_secret']
          end
          provider :cartodb, host, oauth_key, oauth_secret
        end
        init_warden rails_app
      end
      private :init_omniaouth

      def init_warden(rails_app)
        rails_app.middleware.use RailsWarden::Manager do |manager|
          manager.default_strategies :cartodb_oauth
          manager.failure_app = SessionsController if defined?(SessionsController)
        end
      end
      private :init_warden

  end

  class Init

    class << self

      def start(cartodb_settings = nil)
        if cartodb_settings.blank?
          config_path = Rails.root.join('config/cartodb_config.yml')
          cartodb_settings = YAML.load_file(config_path)[Rails.env.to_s] if File.exists?(config_path)
        end

        return if cartodb_settings.blank?

        if CartoDB.const_defined?('Settings')
          CartoDB::Settings.merge!(cartodb_settings)
        else
          CartoDB.const_set('Settings', cartodb_settings)
        end

        CartoDB.const_set('Connection', CartoDB::Client::Connection::Base.new) unless CartoDB.const_defined?('Connection')


      end

    end

  end

end


