# Creates {Metasploit::Credential::Core} objects and their associated {Metasploit::Credential::Public},
# {Metasploit::Credential::Private}, and {Metasploit::Credential::Realm} objects from a CSV file.
#
# Successful import will also create a {Metasploit::Credential::Origin::Import}
#

class Metasploit::Credential::Importer::CSV::Core < Metasploit::Credential::Importer::CSV::Base

  #
  # CONSTANTS
  #

  VALID_CSV_HEADERS = [:public, :private, :realm_type, :realm_name]

end