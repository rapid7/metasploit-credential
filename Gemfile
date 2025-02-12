source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'metasploit-model', git: 'https://github.com/cdelafuente-r7/metasploit-model', branch: 'feat/model/search/operation/jsonb'

group :development do
  # Entity-Relationship diagrams for developers that need to access database using SQL directly.
  gem 'rails-erd'
  # markdown formatting for yard
  gem 'redcarpet'
  gem 'yard'
  gem 'e2mmap'
  gem 'pry-byebug'
end

group :development, :test do
  # Temporary, remove once the Rails 7.1 update is complete
  # see: https://stackoverflow.com/questions/79360526/uninitialized-constant-activesupportloggerthreadsafelevellogger-nameerror
  gem 'concurrent-ruby', '1.3.4'

  # Hash password for Metasploit::Credential::PasswordHash factories
  gem 'bcrypt'
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
  gem 'rails', '7.0.8'
  # running documentation generation tasks and rspec tasks
  gem 'rake'
  # unit testing framework with rails integration
  gem 'rspec-rails'
end
