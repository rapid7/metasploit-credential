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
          g.helper false
          g.test_framework :rspec, fixture: false
        end

        isolate_namespace(Metasploit::Credential)
      end
    end
  end
end