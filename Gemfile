source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'metasploit-model', github: 'rapid7/metasploit-model', ref: 'd25cd50353aa6a25fb1b84b158737810c77bad50'

# This isn't in gemspec because metasploit-framework has its own patched version of 'net/ssh' that it needs to use
# instead of this gem.
# Metasploit::Credential::SSHKey validation and helper methods
gem 'net-ssh'

group :development do
  # markdown formatting for yard
  gem 'kramdown', platforms: :jruby
  # Entity-Relationship diagrams for developers that need to access database using SQL directly.
  gem 'rails-erd'
  # markdown formatting for yard
  gem 'redcarpet', platforms: :ruby
  # documentation
  # 0.8.7.4 has a bug where setters are not documented when @!attribute is used
  gem 'yard', '< 0.8.7.4'
end

group :development, :test do
  # Hash password for Metasploit::Credential::PasswordHash factories
  gem 'bcrypt'
    # Uploads simplecov reports to coveralls.io
  gem 'coveralls', require: false
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
  # for dummy app
  gem 'rails', '>= 4.0.9', '< 4.1.0'
  # unit testing framework with rails integration
  gem 'rspec-rails', '~> 3.1'
end
