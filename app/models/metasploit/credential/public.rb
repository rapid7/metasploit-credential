# A publicly disclosed credential, i.e. a {#username}.
class Metasploit::Credential::Public < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute cores
  #   The {Metasploit::Credential::Core core credentials} that combine this public credential with its derived
  #   {Metasploit::Credential::Private private credential} and/or {Metasploit::Credential::Realm realm}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Credential::Core>]
  has_many :cores,
           class_name: 'Metasploit::Credential::Core',
           dependent: :destroy,
           inverse_of: :public

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

  Metasploit::Concern.run(self)
end
