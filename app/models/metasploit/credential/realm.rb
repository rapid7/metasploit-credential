# The realm in which a {Metasploit::Credential::Public} can be used to authenticate or from which a
# {Metasploit::Credential::Private} was looted.
class Metasploit::Credential::Realm < ActiveRecord::Base
  extend ActiveSupport::Autoload

  autoload :Key

  #
  # Associations
  #

  # @!attribute cores
  #   The {Metasploit::Credential::Core core credentials} that combine this realm with
  #   {Metasploit::Credential::Private private credentials} and/or {Metasploit::Credential::Public public credentials}
  #   gathered from the realm or used to authenticated to the realm.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Credential::Core>]
  has_many :cores,
           class_name: 'Metasploit::Credential::Core',
           dependent: :destroy,
           inverse_of: :realm

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
  #   @return [String] An element of `Metasploit::Model::Realm::Key::ALL`

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
                in: Metasploit::Model::Realm::Key::ALL
            },
            presence: true
  validates :value,
            presence: true,
            uniqueness: {
                scope: :key
            }

  Metasploit::Concern.run(self)
end
