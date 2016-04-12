source "https://rubygems.org"

# Declare your gem's dependencies in metasploit-credential.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec
# rails-upgrade staging gems
 gem 'metasploit-yard',        github: 'rapid7/metasploit-yard',        branch: 'staging/rails-upgrade'
 gem 'metasploit-erd',         github: 'rapid7/metasploit-erd',         branch: 'staging/rails-upgrade'
 gem 'yard-metasploit-erd',    github: 'rapid7/yard-metasploit-erd',    branch: 'staging/rails-upgrade'
 gem 'metasploit-concern',     github: 'rapid7/metasploit-concern',     branch: 'staging/rails-upgrade'
 gem 'metasploit-model',       github: 'rapid7/metasploit-model',       branch: 'staging/rails-upgrade'
 gem 'metasploit_data_models', github: 'rapid7/metasploit_data_models', branch: 'staging/rails-upgrade'

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
  gem 'factory_girl'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations, and have_db_*
  # for testing database columns and indicies.
  gem 'shoulda-matchers'
  # code coverage of tests
  gem 'simplecov', :require => false
  # dummy app
  gem 'rails', '~> 4.1.15'
  # running documentation generation tasks and rspec tasks
  gem 'rake'
  # unit testing framework with rails integration
  gem 'rspec-rails'
end
