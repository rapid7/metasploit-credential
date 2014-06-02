$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'metasploit/credential/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'metasploit-credential'
  s.version     = Metasploit::Credential::VERSION
  s.authors     = ['Luke Imhoff', 'Trevor Rosen']
  s.email       = ['luke_imhoff@rapid7.com', 'trevor_rosen@rapid7.com']
  s.homepage    = 'https://github.com/rapid7/metasploit-credential'
  s.license     = 'BSD-3-clause'
  s.summary     = 'Credential models for metasploit-framework and Metasploit Pro'
  s.description = 'The Metasploit::Credential namespace and its ActiveRecord::Base subclasses'

  s.files = Dir['{app,config,db,lib,spec}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = s.files.grep(/spec/)

  s.add_development_dependency 'pg'

  # patching inverse association in Mdm models.
  # TODO change version to '~> 0.1.0' when metasploit-concern 0.1.0 is released to rubygems.
  s.add_runtime_dependency 'metasploit-concern', '~> 0.1.0.pre.use.pre.metasploit.pre.concern.pre.in.pre.pro'
  # Various Metasploit::Credential records have associations to Mdm records
  s.add_runtime_dependency 'metasploit_data_models', '~> 0.17.0'
  # Metasploit::Credential::NTLMHash helper methods
  s.add_runtime_dependency 'rubyntlm'
  # Required for supporting the en masse importation of SSH keys
  s.add_development_dependency 'rubyzip'
end
