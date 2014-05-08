module Metasploit::Credential::Importer
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :CSV
  autoload :MsfPwdump
  autoload :Zip
end