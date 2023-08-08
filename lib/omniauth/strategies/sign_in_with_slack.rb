require "omniauth_openid_connect"

module OmniAuth
  module Strategies
    class SignInWithSlack < OmniAuth::Strategies::OpenIDConnect
      args %i[client_id client_secret]

      option :name, "slack"
      option :issuer, "https://slack.com"
      option :discovery, true
      option :scope, %w[openid email profile]

      def initialize(*args, &block)
        super
        options.client_options.identifier = options.client_id
        options.client_options.secret = options.client_secret
      end

      def redirect_uri
        full_host + script_name + callback_path
      end
    end
  end
end
