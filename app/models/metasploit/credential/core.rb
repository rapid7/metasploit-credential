# Core credential that combines {#private}, {#public}, and/or {#realm} so that {Metasploit::Credential::Private} or
# {Metasploit::Credential::Public} that are gathered from a {Metasploit::Credential::Realm} are properly scoped when
# used.
#
# A core credential must always have an {#origin}, but only needs 1 of {#private}, {#public}, or {#realm} set.
class Metasploit::Credential::Core < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute logins
  #   The {Metasploit::Credential::Login logins} using this core credential to log into a service.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Credential::Login>]
  has_many :logins,
           class_name: 'Metasploit::Credential::Login',
           dependent: :destroy,
           inverse_of: :core

  # @!attribute origin
  #   The origin of this core credential.
  #
  #   @return [Metasploit::Credential::Origin::Import] if this core credential was bulk imported by a
  #     {Metasploit::Credential::Origin::Import#task task}.
  #   @return [Metasploit::Credential::Origin::Manual] if this core credential was manually entered by a
  #     {Metasploit::Credential::Origin::Manual#user user}.
  #   @return [Metasploit::Credential::Origin::Service] if this core credential was gathered from a
  #     {Metasploit::Credential::Origin::Service#service service} using an
  #     {Metasploit::Credential::Origin::Service#module_full_name auxiliary or exploit module}.
  #   @return [Metasploit::Credential::Origin::Session] if this core credential was gathered using a
  #     {Metasploit::Credential::Origin::Session#post_reference_name post module} attached to a
  #     {Metasploit::Credential::Origin::Session#session session}.
  belongs_to :origin,
             polymorphic: true

  # @!attribute private
  #   The {Metasploit::Credential::Private} either gathered from {#realm} or used to
  #   {Metasploit::Credential::ReplayableHash authenticate to the realm}.
  #
  #   @return [Metasploit::Credential::Private, nil]
  belongs_to :private,
             class_name: 'Metasploit::Credential::Private',
             inverse_of: :cores

  # @!attribute public
  #   The {Metasploit::Credential::Public} gathered from {#realm}.
  #
  #   @return [Metasploit::Credential::Public, nil]
  belongs_to :public,
             class_name: 'Metasploit::Credential::Public',
             inverse_of: :cores

  # @!attribute realm
  #   The {Metasploit::Credential::Realm} where {#private} and/or {#public} was gathered and/or the
  #   {Metasploit::Credential::Realm} to which {#private} and/or {#public} can be used to authenticate.
  #
  #   @return [Metasploit::Credential::Realm, nil]
  belongs_to :realm,
             class_name: 'Metasploit::Credential::Realm',
             inverse_of: :cores

  # @!attribute workspace
  #   The `Mdm::Workspace` to which this core credential is scoped.  Used to limit mixing of different networks
  #   credentials.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :core_credentials

  #
  # Attributes
  #

  # @!attribute created_at
  #   When this core credential was created.
  #
  #   @return [DateTime]

  # @!attribute updated_at
  #   When this core credential was last updated.
  #
  #   @return [DateTime]

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :consistent_workspaces
  validate :minimum_presence

  #
  # Attribute Validations
  #

  validates :origin,
            presence: true
  validates :workspace,
            presence: true

  #
  # Instance Methods
  #

  private

  # Validates that the direct {#workspace} is consistent with the `Mdm::Workspace` accessible through the {#origin}.
  #
  # @return [void]
  def consistent_workspaces
    case origin
      when Metasploit::Credential::Origin::Import
        unless self.workspace == origin.task.try(:workspace)
          errors.add(:workspace, :origin_task_workspace)
        end
      when Metasploit::Credential::Origin::Manual
        user = origin.user

        # admins can access any workspace so there's no inconsistent workspace
        unless user &&
               (
                user.admin ||
                # use database query when possible
                (
                 user.persisted? &&
                 user.workspaces.exists?(self.workspace.id)
                ) ||
                # otherwise fall back to in-memory query
                user.workspaces.include?(self.workspace)
               )
          errors.add(:workspace, :origin_user_workspaces)
        end
      when Metasploit::Credential::Origin::Service
        unless self.workspace == origin.service.try(:host).try(:workspace)
          errors.add(:workspace, :origin_service_host_workspace)
        end
      when Metasploit::Credential::Origin::Session
        unless self.workspace == origin.session.try(:host).try(:workspace)
          errors.add(:workspace, :origin_session_host_workspace)
        end
    end
  end

  # Validates that at least one of {#private}, {#public}, or {#realm} is present.
  #
  # @return [void]
  def minimum_presence
    any_present = [:private, :public, :realm].any? { |attribute|
      send(attribute).present?
    }

    unless any_present
      errors.add(:base, :minimum_presence)
    end
  end
end
