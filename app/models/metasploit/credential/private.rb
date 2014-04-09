# Base `Class` for all private credentials.   A private credential is any credential that should not be publicly
# disclosed, such as a {Metasploit::Credential::Password password}, password hash, or key file.
#
# Uses Single Table Inheritance to store subclass name in {#type} per Rails convention.
class Metasploit::Credential::Private < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute data
  #   The private data for this credential.  The semantic meaning of this data varies based on subclass.
  #
  #   @return [String]

  # @!attribute id
  #   The id of this private credential in the database.  {#id} sequence is shared across all subclass {#type}s, so
  #   {#id} alone acts as a primary key without the need for a compound primary key (id, type).
  #
  #   @return [Integer] if saved to database.
  #   @return [nil] if not saved to database.

  # @!attribute type
  #   The name of the `Class`.  Used to instantiate the correct subclass when retrieving records from the database.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :data

  #
  # Validations
  #

  validates :data,
            non_nil: true,
            uniqueness: {
                scope: :type
            }
end
