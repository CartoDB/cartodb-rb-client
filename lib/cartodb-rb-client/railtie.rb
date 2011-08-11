require 'warden'
require 'rails_warden'
require 'omniauth'
require 'multi_json'

require 'cartodb-rb-client/railties/omniauth_cartodb_authentication'
require 'cartodb-rb-client/railties/warden_strategies'

module CartoDB
  class Railtie < Rails::Railtie

    initializer "cartoDB_railtie.configure_rails_initialization" do |app|

      CartoDB::Init.start app

    end

  end

  class Init

    class << self

      def start(rails_app, cartodb_settings = nil)
        if cartodb_settings.blank?
          config_path = Rails.root.join('config/cartodb_config.yml')
          cartodb_settings = YAML.load_file(config_path)[Rails.env.to_s] if File.exists?(config_path)
        end

        return if CartoDB.const_defined?('Settings') || cartodb_settings.blank?

        CartoDB.const_set('Settings', cartodb_settings)
        CartoDB.const_set('Connection', CartoDB::Client::Connection::Base.new) unless CartoDB.const_defined?('Connection')

        init_omniaouth rails_app
        init_warden rails_app

      end

      def init_omniaouth(rails_app)
        rails_app.middleware.use OmniAuth::Builder do
          provider :cartodb, CartoDB::Settings['host'], CartoDB::Settings['oauth_key'], CartoDB::Settings['oauth_secret']
        end
      end
      private :init_omniaouth

      def init_warden(rails_app)
        rails_app.middleware.use RailsWarden::Manager do |manager|
          manager.default_strategies :cartodb_oauth
          manager.failure_app = SessionsController if SessionsController
        end
      end
      private :init_warden

    end

  end

end