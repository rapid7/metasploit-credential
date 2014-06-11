module Metasploit::Credential::Importer
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Core
  autoload :MsfPwdump
  autoload :Zip
  autoload :Multi
end