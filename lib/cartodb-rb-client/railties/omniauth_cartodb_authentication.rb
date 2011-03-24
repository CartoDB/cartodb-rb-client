module OmniAuth
  module Strategies
    class Cartodb < OmniAuth::Strategies::OAuth
      def initialize(app, site, app_id, app_secret, options = {})
        options[:site] = site
        options[:authorize_path] = '/oauth/authorize'
        options[:access_token_path] = '/oauth/access_token'
        options[:callback_url] = '/auth/oauth/callback'
        super(app, :cartodb, app_id, app_secret, options)
      end

      def user_data
        @user_data ||= MultiJson.decode(@access_token.get('/oauth/identity.json').body)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid'          => user_data['uid'],
          'username'     => user_data['username'],
          'email'        => user_data['email'],
          'oauth_key'    => user_data['oauth_key'],
          'oauth_secret' => user_data['oauth_secret']
        })
      end
    end
  end
end