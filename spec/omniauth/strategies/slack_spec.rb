require "rack/test"
require "omniauth/test"
require "omniauth/strategies/slack"

RSpec.describe OmniAuth::Strategies::Slack do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: "slack-cookie"
      b.use OmniAuth::Strategies::Slack, client_id: "c_id", client_secret: "c_secret", require_state: false
      b.run lambda { |_env| [200, {}, "Hello"] }
    end
  end

  before(:all) do
    OmniAuth.config.logger = Logger.new("/dev/null")
    OmniAuth.config.request_validation_phase = nil
  end

  context "request phase" do
    it "redirects to slack" do
      post "/auth/slack"

      loc = last_response.header["Location"]
      expect(loc).to start_with("https://slack.com/openid/connect/authorize")
      expect(loc).to include("client_id=c_id")
      expect(loc).to include("scope=openid%20email%20profile")
    end
  end

  context "callback phase" do
    let(:slack_info) do
      {
        "ok" => true,
        "sub" => "UBD2CE89FJU",
        "https://slack.com/user_id" => "UBD2CE89FJU",
        "https://slack.com/team_id" => "T7F342D542B",
        "email" => "andre@example.com",
        "email_verified" => true,
        "date_email_verified" => 1688147930,
        "name" => "André Arko",
        "picture" => "https://avatars.slack-edge.com/2023-06-07/abc_123_512.jpg",
        "given_name" => "André",
        "family_name" => "Arko",
        "locale" => "en-US",
        "https://slack.com/team_name" => "Example Team",
        "https://slack.com/team_domain" => "example-team",
        "https://slack.com/user_image_24" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_24.jpg",
        "https://slack.com/user_image_32" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_32.jpg",
        "https://slack.com/user_image_48" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_48.jpg",
        "https://slack.com/user_image_72" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_72.jpg",
        "https://slack.com/user_image_192" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_192.jpg",
        "https://slack.com/user_image_512" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_512.jpg",
        "https://slack.com/user_image_1024" =>
         "https://avatars.slack-edge.com/2023-06-07/abc_123_1024.jpg",
        "https://slack.com/team_image_34" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_34.png",
        "https://slack.com/team_image_44" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_44.png",
        "https://slack.com/team_image_68" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_68.png",
        "https://slack.com/team_image_88" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_88.png",
        "https://slack.com/team_image_102" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_102.png",
        "https://slack.com/team_image_132" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_132.png",
        "https://slack.com/team_image_230" =>
         "https://avatars.slack-edge.com/2023-06-28/abc_123_230.png",
        "https://slack.com/team_image_default" => false,
        "iss" => "https://slack.com",
        "aud" => "1615ac2407f901bbfbe37e464cdf03e1",
        "exp" => 1691530230,
        "iat" => 1691529930,
        "auth_time" => 1691529930,
        "nonce" => "d1c806e995bb500b42493da245a71d4a53aa115a192cc28ff64b7b205bdc72b4",
        "at_hash" => "b443e728978e2dc7450cc1e039846d61"
      }.symbolize_keys
    end

    let(:auth_hash) { last_request.env["omniauth.auth"] }
    let(:identifier) { "1234" }
    let(:secret) { "1234asdgat3" }
    let(:issuer) { "https://slack.com" }
    let(:nonce) { SecureRandom.hex(16) }

    def payload
      {
        iss: issuer,
        aud: identifier,
        sub: "248289761001",
        nonce: nonce,
        exp: Time.now.to_i + 1000,
        iat: Time.now.to_i
      }
    end

    def private_key
      @private_key ||= OpenSSL::PKey::RSA.generate(512)
    end

    def jwt
      @jwt ||= JSON::JWT.new(payload).sign(private_key, :RS256)
    end

    def jwks
      @jwks ||= begin
        key = JSON::JWK.new(private_key)
        keyset = JSON::JWK::Set.new(key)
        {keys: keyset}
      end
    end

    def user_info
      @user_info ||= OpenIDConnect::ResponseObject::UserInfo.new(slack_info)
    end

    it "parses the slack user info" do
      oidc_issuer = double("OpenIDConnect::Discovery::Issuer", issuer: issuer)
      allow(::OpenIDConnect::Discovery::Provider).to receive(:discover!).and_return(oidc_issuer)

      config = double("OpenIDConnect::Discovery::Provder::Config",
        authorization_endpoint: "https://example.com/authorization",
        token_endpoint: "https://example.com/token",
        userinfo_endpoint: "https://example.com/userinfo",
        jwks_uri: "https://example.com/jwks",
        jwks: JSON::JWK::Set.new(jwks["keys"]))

      expect(::OpenIDConnect::Discovery::Provider::Config).to receive(:discover!).with(issuer).and_return(config)

      id_token = double("OpenIDConnect::ResponseObject::IdToken",
        raw_attributes: {"sub" => "sub", "name" => "name", "email" => "email"},
        verify!: true)
      allow(::OpenIDConnect::ResponseObject::IdToken).to receive(:decode).and_return(id_token)

      access_token = double("OpenIDConnect::AccessToken",
        access_token: true,
        refresh_token: true,
        expires_in: true,
        scope: true,
        id_token: jwt.to_s)
      expect_any_instance_of(::OpenIDConnect::Client).to receive(:access_token!).and_return(access_token)
      expect(access_token).to receive(:userinfo!).and_return(user_info)

      post "/auth/slack/callback", code: jwt.to_s
      auth_info = last_request.env["omniauth.auth"]
      expect(auth_info.dig(:provider)).to eq("slack")
      expect(auth_info.dig(:info, :email)).to eq("andre@example.com")
    end
  end
end
