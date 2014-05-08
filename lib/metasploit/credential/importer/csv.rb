# Provides loading for CSV submodules
module Metasploit::Credential::Importer::CSV
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Core
  autoload :Manifest
end