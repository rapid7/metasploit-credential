begin
  require 'rails'
rescue LoadError => error
  warn "rails could not be loaded, so Metasploit::Credential::Engine will not be defined: #{error}"
else
  module Metasploit
    module Credential
      # Rails engine for Metasploit::Credential.  Will automatically be used if `Rails` is defined when
      # 'metasploit/credential' is required, as should be the case in any normal Rails application Gemfile where
      # gem 'rails' is the first gem in the Gemfile.
      class Engine < Rails::Engine
        # @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
        config.generators do |g|
          g.assets false
          g.fixture_replacement :factory_girl, dir: 'spec/factories'
          g.helper false
          g.test_framework :rspec, fixture: false
        end

        config.paths.add 'app/concerns', autoload: true
        config.paths.add 'lib', autoload: true

        initializer 'metasploit_credential.prepend_factory_path', after: 'factory_girl.set_factory_paths' do
          if defined? FactoryGirl
            relative_definition_file_path = config.generators.options[:factory_girl][:dir]
            definition_file_path = root.join(relative_definition_file_path)

            # unshift so that projects that use metasploit-credential can modify metasploit_credential_* factories
            FactoryGirl.definition_file_paths.unshift definition_file_path
          end
        end
      end
    end
  end
end
