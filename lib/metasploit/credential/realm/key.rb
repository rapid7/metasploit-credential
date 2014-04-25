# Canonical {Metasploit::Credential::Realm#key  Metasploit::Credential::Realm#keys}.
#
# {Metasploit::Credential::Realm#key} is restricted to values in {ALL}, so new valid values need to be added to this
# module:
#
# 1. Add a String constant where the constant name is in SCREAMING_SNAKE_CASE and the String in Title Case.
# 2. Add the new constant to {ALL}.
module Metasploit::Credential::Realm::Key
  #
  # CONSTANTS
  #

  # An Active Directory domain that is used for authenication in Windows environments.
  #
  # @see https://en.wikipedia.org/wiki/Active_Directory
  ACTIVE_DIRECTORY_DOMAIN = 'Active Directory Domain'

  # A System Identifier for an Oracle Database.
  #
  # @see http://docs.oracle.com/cd/E11882_01/server.112/e40540/startup.htm#CNCPT89037
  ORACLE_SYSTEM_IDENTIFIER = 'Oracle System Identifier'

  # A PostgreSQL database name.  Unlike, MySQL, PostgreSQL requires the user to authenticate to a specific
  # database and does not allow authenticating to just a server (which would be an `Mdm::Service`).
  POSTGRESQL_DATABASE = 'PostgreSQL Database'

  # All values that are valid for {Metasploit::Credential::Realm#key}.
  ALL = [
      ACTIVE_DIRECTORY_DOMAIN,
      ORACLE_SYSTEM_IDENTIFIER,
      POSTGRESQL_DATABASE
  ]
end