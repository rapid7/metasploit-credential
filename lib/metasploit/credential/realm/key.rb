# Canonical {Metasploit::Credential::Realm#key  Metasploit::Credential::Realm#keys}.  If a key is used more than once,
# then it should be added as a constant on this `Module` and that constant should be used in place of a bare `String`
# as it ensure consistent key spelling and capitalization and allows for easier locating usage and refactoring in the
# future.
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
end