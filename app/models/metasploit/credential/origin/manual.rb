# Origin of credentials that are manually entered by a {#user}.
class Metasploit::Credential::Origin::Manual < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute user
  #   The user that manually enters the credentials.
  #
  #   @return [Mdm::User]
  #   @todo Add `inverse_of: :manual_credential_origins` when metasploit-concern is available to patch `Mdm::User`
  belongs_to :user,
             class_name: 'Mdm::User'

  #
  # Attribute
  #

  # @!attribute created_at
  #   When the credentials were manually created.
  #
  #   @return [DateTime]

  # @!attribute updated_at
  #   When this origin was last updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :user,
            presence: true
end
