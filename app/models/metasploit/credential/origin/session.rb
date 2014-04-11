# Origin of `Metasploit::Credential::Core`s that were gathered by a {#post_reference_name post module} used on a
# {#session}.  Contrast with a {Metasploit::Credential::Origin::Service}, which is for
# {Metasploit::Credential::Origin::Service#module_full_name auxiliary or exploit modules} that gather credentials
# directly from a {Metasploit::Credential::Origin::Service#service service} without the need for a separate post module
# or even a session.
class Metasploit::Credential::Origin::Session < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute session
  #   The session on which {#post_reference_name the post module} was run to gather the `Metasploit::Credential::Core`s.
  #
  #   @return [Mdm::Session]
  #   @todo Add `inverse_of: :credential_origins` when metasploit-concern is availabe to add association to `Mdm::Session`.
  belongs_to :session,
             class_name: 'Mdm::Session'

  #
  # Attributes
  #

  # @!attribute post_reference_name
  #   The reference name of a `Msf::Post` module.
  #
  #   @return [String] a `Mdm::Module::Detail#refname` for a `Mdm::Module::Detail` where `Mdm::Module:Detail#mtype` is
  #     `'post'.`

  #
  # Mass Assignment Security
  #

  attr_accessible :post_reference_name

  #
  # Validations
  #

  validates :post_reference_name,
            presence: true,
            uniqueness: {
                scope: :session_id
            }
  validates :session,
            presence: true
end
