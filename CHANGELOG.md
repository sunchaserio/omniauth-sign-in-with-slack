## [Unreleased]

- Nothing yet

## [1.1.0] 2023-08-19

- Support the `team` parameter sent to the `omniauth_authorize_path`. By including `team` in the redirect URL, Slack can automatically choose the correct team out of all the teams you are logged in to already. This can save a lot of confusion and mis-installs.

## [1.0.0] 2023-08-08

- Initial release
- Contains `OmniAuth::Strategies::Slack` for OIDC Sign in with Slack
