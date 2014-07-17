# The use of a {#core core credential} against a {#service service}.
class Metasploit::Credential::Login < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Search

  #
  # Associations
  #
  
  # @!attribute tasks
  #   The {Mdm::Task tasks} using this to track what tasks interacted with a given core.
  #
  #   @return [ActiveRecord::Relation<Mdm::Task>]
  has_and_belongs_to_many :tasks, 
                          class_name: "Mdm::Task", 
                          join_table: "credential_logins_tasks",
                          uniq: true

  # @!attribute core
  #   The {Metasploit::Credential::Core core credential} used to authenticate to {#service}.
  #
  #   @return [Metasploit::Credential::Core]
  belongs_to :core,
             class_name: 'Metasploit::Credential::Core',
             inverse_of: :logins,
             counter_cache: true

  # @!attribute service
  #   The service that either accepted the {#core core credential} as valid, invalid, or on which the
  #   {#core core credential} should be tested to see if it is valid.
  #
  #   @return [Mdm::Service]
  belongs_to :service,
             class_name: 'Mdm::Service',
             inverse_of: :logins

  #
  # Attributes
  #

  # @!attribute access_level
  #   @note An empty string is converted to `nil` before saving.
  #
  #   A free-form text field that the user can use annotate the access level of this login, such as `'admin'`.
  #
  #   @return [String] The value entered by the user.
  #   @return [nil] When the user has not entered a value.

  # @!attribute created_at
  #   When this login was created.
  #
  #   @return [DateTime]

  # @!attribute last_attempted_at
  #   @note This is the last time this login was attempted and should be updated even if {#status} does not change.  If
  #   {#status} does not change, then normally {#updated_at} would be updated as the record would not save.
  #
  #   The last time a login was attempted.
  #
  #   @return [DateTime]

  # @!attribute status
  #   The status of this login, such as whether it is
  #   `Metasploit::Model::Login::Status::DENIED_ACCESS`,
  #   `Metasploit::Model::Login::Status::DISABLED`,
  #   `Metasploit::Model::Login::Status::LOCKED_OUT`,
  #   `Metasploit::Model::Login::Status::SUCCESSFUL`,
  #   `Metasploit::Model::Login::Status::UNABLE_TO_CONNECT`,
  #   `Metasploit::Model::Login::Status::UNTRIED`
  #
  #   @return [String] An element of `Metasploit::Model::Login::Status::ALL`

  # @!attribute updated_at
  #   The last time this login was updated.
  #
  #   @return [DateTime]

  #
  # Callbacks
  #

  before_validation :blank_to_nil

  #
  # Mass Assignment Security
  #

  attr_accessible :access_level
  attr_accessible :last_attempted_at
  attr_accessible :status

  #
  # Search
  #

  search_attribute :access_level,
                   type: :string

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :consistent_last_attempted_at
  validate :consistent_workspaces

  #
  # Attribute Validations
  #

  validates :core,
            presence: true
  validates :core_id,
            uniqueness: {
                scope: :service_id
            }
  validates :service,
            presence: true
  validates :status,
            inclusion: {
                in: Metasploit::Model::Login::Status::ALL
            }


  #
  # Scopes
  #

  # Finds all {Metasploit::Credential::Login} objects that are associated with a given `Mdm::Workspace`
  # @method in_workspace_including_hosts_and_services
  # @scope Metasploit::Credential::Login
  # @param workspace [Mdm::Workspace] the workspace to filter by
  # @return [ActiveRecord::Relation] containing the logins
  scope :in_workspace_including_hosts_and_services, ->(workspace) {
    host_workspace_column = Mdm::Host.arel_table[:workspace_id]
    joins(service: :host).includes(core: [:public, :private], service: :host).where(host_workspace_column.eq(workspace.id))
  }



  #
  # Instance Methods
  #

  private

  # Converts blank {#access_level} to `nil`.
  #
  # @return [void]
  def blank_to_nil
    if access_level.blank?
      self.access_level = nil
    end
  end

  # Validates that {#last_attempted_at} is `nil` when {#status} is {Metasploit:Credential::Login::Status::UNTRIED} and
  # that {#last_attempted_at} is not `nil` when {#status} is not {Metasploit:Credential::Login::Status::UNTRIED}.
  #
  # @return [void]
  def consistent_last_attempted_at
    if status == Metasploit::Model::Login::Status::UNTRIED
      unless last_attempted_at.nil?
        errors.add(:last_attempted_at, :untried)
      end
    else
      if last_attempted_at.nil?
        errors.add(:last_attempted_at, :tried)
      end
    end
  end

  # Validates the {#service service's} `Mdm::Service#host`'s `Mdm::Host#workspace` matches {#core core's}
  # {Metasploit::Credential::Core#workspace}.
  def consistent_workspaces
    unless core.try(:workspace) == service.try(:host).try(:workspace)
      errors.add(:base, :inconsistent_workspaces)
    end
  end

  public

  Metasploit::Concern.run(self)
end
