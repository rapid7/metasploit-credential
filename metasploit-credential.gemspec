$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'metasploit/credential/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'metasploit-credential'
  s.version     = Metasploit::Credential::VERSION
  s.authors     = ['Metasploit Hackers']
  s.email       = ['msfdev@metasploit.com']
  s.homepage    = 'https://github.com/rapid7/metasploit-credential'
  s.license     = 'BSD-3-clause'
  s.summary     = 'Credential models for metasploit-framework and Metasploit Pro'
  s.description = 'The Metasploit::Credential namespace and its ActiveRecord::Base subclasses'

  s.files = Dir['{app,config,db,lib,spec}/**/*'] + ['CONTRIBUTING.md', 'LICENSE', 'Rakefile', 'README.md'] - Dir['spec/dummy/log/*.log']
  s.test_files = s.files.grep(/spec/)
  s.require_paths = %w{app/models app/validators lib}

  s.required_ruby_version = '>= 2.7.0'

  # patching inverse association in Mdm models.
  s.add_runtime_dependency 'metasploit-concern'
  # Various Metasploit::Credential records have associations to Mdm records
  s.add_runtime_dependency 'metasploit_data_models', [">= 5.0.0"]
  # Metasploit::Model::Search
  s.add_runtime_dependency 'metasploit-model'

  s.add_runtime_dependency 'railties'
  # Metasploit::Credential::NTLMHash helper methods
  s.add_runtime_dependency 'rubyntlm'
  # Required for supporting the en masse importation of SSH Keys
  s.add_runtime_dependency 'rubyzip', '<3.0.0'

  s.add_runtime_dependency 'rex-socket'

  s.add_runtime_dependency 'net-ssh'

  s.add_runtime_dependency 'pg'

  # mutex_m and bigdecimal are not part of the default gems starting from Ruby 3.4.0: https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-3-0-released/
  %w[
    bigdecimal
    csv
    drb
    mutex_m
  ].each do |library|
    s.add_runtime_dependency library
  end

  s.platform = Gem::Platform::RUBY
end
