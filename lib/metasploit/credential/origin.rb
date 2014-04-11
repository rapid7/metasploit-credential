# Namespace for `Metasploit::Credential::Core#origin`s for `Metasploit::Credential::Core`s.
module Metasploit::Credential::Origin
  # The prefix for table name of `ActiveRecord::Base` subclasses in the namespace.
  #
  # @return [String] `'metasploit_credential_origin_'`
  def self.table_name_prefix
    'metasploit_credential_origin_'
  end
end
