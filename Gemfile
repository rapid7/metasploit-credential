source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development do
  # Entity-Relationship diagrams for developers that need to access database using SQL directly.
  gem 'rails-erd'
  # markdown formatting for yard
  gem 'redcarpet'
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
  gem 'factory_bot'
  # auto-load factories from spec/factories
  gem 'factory_bot_rails'
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'
  # Used by the Metasploit data model, etc.
  # bound to 0.20 for Activerecord 4.2.8 deprecation warnings:
  # https://github.com/ged/ruby-pg/commit/c90ac644e861857ae75638eb6954b1cb49617090
  gem 'pg'
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations, and have_db_*
  # for testing database columns and indicies.
  gem 'shoulda-matchers'
  # code coverage of tests
  gem 'simplecov', :require => false
  # dummy app
  gem 'rails', '~> 5.2.2'
  # running documentation generation tasks and rspec tasks
  gem 'rake'
  # unit testing framework with rails integration
  gem 'rspec-rails'
end
