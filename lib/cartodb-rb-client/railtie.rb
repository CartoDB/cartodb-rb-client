require 'warden'
require 'rails_warden'
require 'omniauth'
require 'multi_json'

require 'cartodb-rb-client/railties/omniauth_cartodb_authentication'
require 'cartodb-rb-client/railties/warden_strategies'

module CartoDB
  class Railtie < Rails::Railtie

    initializer "cartoDB_railtie.configure_rails_initialization" do |app|

      CartoDB::Settings = YAML.load_file(Rails.root.join('config/cartodb_config.yml'))[Rails.env.to_s]
      CartoDB::Connection = CartoDB::Client.new

      app.middleware.use OmniAuth::Builder do
        provider :cartodb, CartoDB::Settings['host'], CartoDB::Settings['oauth_key'], CartoDB::Settings['oauth_secret']
      end

      app.middleware.use RailsWarden::Manager do |manager|
        manager.default_strategies :cartodb_oauth
        manager.failure_app = SessionsController if SessionsController
      end

    end

  end

end