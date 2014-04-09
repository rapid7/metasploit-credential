source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec


group :development, :test do
  # Hash password for Metasploit::Credential::PasswordHash factories
  gem 'bcrypt'
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryGirl.' in factory definitions syntax.
  gem 'factory_girl', '>= 4.1.0'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations, and have_db_*
  # for testing database columns and indicies.
  gem 'shoulda-matchers'
  # code coverage of tests
  gem 'simplecov', :require => false
  # restrict for compatibility with rest of metasploit ecosystem until it upgrades to Rails 4
  # @todo MSP-9647
  gem 'rails', '>= 3.2', '< 4.0.0'
  # unit testing framework with rails integration
  gem 'rspec-rails'
end
