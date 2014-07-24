# Namespace for `Metasploit::Credential::Core#origin`s for `Metasploit::Credential::Core`s.
module Metasploit::Credential::Origin
  #
  # CONSTANTS
  #

  # All valid origin types
  VALID_TYPES = [
      Metasploit::Credential::Origin::CrackedPassword,
      Metasploit::Credential::Origin::Import,
      Metasploit::Credential::Origin::Manual,
      Metasploit::Credential::Origin::Service,
      Metasploit::Credential::Origin::Session
  ].collect { |klass| klass.model_name.human }

  # The prefix for table name of `ActiveRecord::Base` subclasses in the namespace.
  #
  # @return [String] `'metasploit_credential_origin_'`
  def self.table_name_prefix
    'metasploit_credential_origin_'
  end
end
