$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'metasploit/credential/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'metasploit-credential'
  s.version     = Metasploit::Credential::VERSION
  s.authors     = ['Luke Imhoff']
  s.email       = ['luke_imhoff@rapid7.com']
  s.homepage    = 'https://github.com/rapid7/metasploit-credential'
  s.summary     = 'Credential models for metasploit-framework and Metasploit Pro'
  s.description = 'The Metasploit::Credential namespace and its ActiveRecord::Base subclasses'

  s.files = Dir['{app,config,db,lib,spec}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = s.files.grep(/spec/)

  # documentation
  # 0.8.7.4 has a bug where setters are not documented when @!attribute is used
  s.add_development_dependency 'yard', '< 0.8.7.4'
  # markdown formatting for yard
  s.add_development_dependency 'redcarpet'

  s.add_development_dependency 'pg'

  # Metasploit::Credential::NTLMHash helper methods
  s.add_runtime_dependency 'rubyntlm'
end
