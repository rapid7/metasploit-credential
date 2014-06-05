# Used for verification and parsing/extraction of zip files
require 'zip/zip'

module Metasploit::Credential::Importer
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :CSV
  autoload :MsfPwdump
  autoload :Zip
  autoload :Multi
end