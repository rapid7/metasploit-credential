$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "metasploit-credential/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "metasploit-credential"
  s.version     = MetasploitCredential::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of MetasploitCredential."
  s.description = "TODO: Description of MetasploitCredential."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.17"

  s.add_development_dependency "pg"
end
