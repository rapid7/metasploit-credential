# An origin for credentials that were imported by a {#task} from a {#filename file}.
class Metasploit::Credential::Origin::Import < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute task
  #   The task that did the import.
  #
  #   @return [Mdm::Task]
  #   @todo Add `inverse_of: :import_credential_origins` when metasploit-concern is available to patch `Mdm::Task`.
  belongs_to :task,
             class_name: 'Mdm::Task'

  #
  # Attribute
  #

  # @!attribute created_at
  #   When the credentials were imported.
  #
  #   @return [DateTime]

  # @!attribute filename
  #   The `File.basename` of the file from which the `Metasploit::Credential::Core`s were imported.  Because only a
  #   basename is available, a {#filename} may be used more than once for the same {#task}.
  #
  #   @return [String]

  # @!attribute updated_at
  #   When this origin was last updated.
  #
  #   @return [DateTime]


  #
  # Mass Assignment Security
  #

  attr_accessible :filename

  #
  # Validations
  #

  validates :filename,
            presence: true
  validates :task,
            presence: true
end
