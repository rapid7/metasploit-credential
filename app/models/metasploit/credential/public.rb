# A publicly disclosed credential, i.e. a {#username}.
class Metasploit::Credential::Public < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute created_at
  #   When this credential was created.
  #
  #   @return [DateTime]

  # @!attribute updated_at
  #   The last time this credential was updated.
  #
  #   @return [DateTime]

  # @!attribute username
  #   The username for this credential
  #
  #   @return [String]

  #
  # Mass-Assignment Security
  #

  attr_accessible :username

  #
  # Validations
  #

  validates :username,
            presence: true,
            uniqueness: true

  ActiveSupport.run_load_hooks(:metasploit_credential_public, self)
end
