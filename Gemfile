source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec


group :development, :test do
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'
  # restrict for compatibility with rest of metasploit ecosystem until it upgrades to Rails 4
  # @todo MSP-9647
  gem 'rails', '>= 3.2', '< 4.0.0'
  # unit testing framework with rails integration
  gem 'rspec-rails'
end
