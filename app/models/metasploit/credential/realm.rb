# The realm in which a {Metasploit::Credential::Public} can be used to authenticate or from which a
# {Metasploit::Credential::Private} was looted.
class Metasploit::Credential::Realm < ActiveRecord::Base
  extend ActiveSupport::Autoload

  autoload :Key

  #
  # Attributes
  #

  # @!attribute created_at
  #   When this realm was created.
  #
  #   @return [DateTime]

  # @!attribute key
  #   @note If a key is used more than once, it should be added to the {Metasploit::Credential::Realm::Key} constants
  #     and that constant should be used in place of the bare string.
  #
  #   The name of the key for the realm.
  #
  #   @return [String] An element of {Metasploit::Credential::Realm::Key::ALL}

  # @!attribute updated_at
  #   The last time this realm was updated.
  #
  #   @return [DateTime]

  # @!attribute value
  #   The value of the {#key} for the realm.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :key
  attr_accessible :value

  #
  # Validations
  #

  validates :key,
            inclusion: {
                in: Metasploit::Credential::Realm::Key::ALL
            },
            presence: true
  validates :value,
            presence: true,
            uniqueness: {
                scope: :key
            }
end