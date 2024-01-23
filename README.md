# Omniauth::SignInWithSlack

An [Omniauth][1] plugin for [the new Sign in With Slack flow][2], which is based on [OIDC][3], an extension of [OAuth 2][4].

## Installation

First, you need to already have [Omniauth][1] installed and set up in your application.

Then, run `bundle add omniauth-sign-in-with-slack`.

[1]: https://github.com/omniauth/omniauth
[2]: https://api.slack.com/authentication/sign-in-with-slack
[3]: https://openid.net/developers/how-connect-works/
[4]: https://oauth.net/2/

## Usage

Follow the [Slack instructions to create a Slack App][5]. After that, browse to "Basic Information" under "Settings", and scroll to the section named "App Credentials". Use the Client ID and Client Secret to configure this gem as an Omniauth provider.

#### With Omniauth & Devise

If you are using Omniauth with [Devise][devise], add these lines to your `devise.rb` configuration file:

```ruby
config.omniauth :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"]
```

[devise]: https://github.com/heartcombo/devise

#### With Omniauth

If you are using Omniauth directly, your configuration will look something like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"]
end
```

[5]: https://api.slack.com/authentication/sign-in-with-slack#setup

### Configuration

You may provide an options hash as the third argument when configuring the provider. Valid options include anything declared by the [OmniAuth::Strategies::OpenIDConnect][6] class. The defaults for this provider are:

1. `name`, default value `"slack"`
1. `issuer`, default value `"https://slack.com"`
1. `scope`, default value `"openid email profile"`

It should not be necessary to set any options for OmniAuth to successfully handle the Sign In With Slack flow.

[6]: https://github.com/omniauth/omniauth_openid_connect#options-overview

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sunchaserio/omniauth-sign-in-with-slack. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sunchaserio/omniauth-sign-in-with-slack/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::SignInWithSlack project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sunchaserio/omniauth-sign-in-with-slack/blob/main/CODE_OF_CONDUCT.md).
