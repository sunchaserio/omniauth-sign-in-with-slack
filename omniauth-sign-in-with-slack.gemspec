Gem::Specification.new do |spec|
  spec.name = "omniauth-sign-in-with-slack"
  spec.version = "1.1.0"
  spec.authors = ["Andre Arko"]
  spec.email = ["andre@arko.net"]

  spec.summary = "Use OmniAuth to Sign in with Slack"
  spec.description = "Use OmniAuth to Sign in with Slack via the new, OIDC-based flow"
  spec.homepage = "https://github.com/sunchaserio/omniauth-sign-in-with-slack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth_openid_connect", "~> 0.7.1"
end
