# Add scopes to the Metasploit::Credential::Core model
module Metasploit::Credential::Core::Scopes
  extend ActiveSupport::Concern

  included do

    #
    # Scopes
    #

    # Finds Cores that have successfully logged into a given host
    #
    # @method login_host_id(host_id)
    # @scope Metasploit::Credential::Core
    # @param host_id [Integer] the host to look for
    # @return [ActiveRecord::Relation] scoped to that host
    scope :login_host_id, lambda { |host_id|
      joins(logins: { service: :host }).where(Mdm::Host.arel_table[:id].eq(host_id))
    }

    # JOINs in origins of a specific type
    #
    # @method origins(origin_class)
    # @scope Metasploit::Credential::Core
    # @param origin_class [ActiveRecord::Base] the Origin class to look up
    # @return [ActiveRecord::Relation] scoped to that origin
    scope :origins, lambda { |origin_class|
      core_table   = Metasploit::Credential::Core.arel_table
      origin_table = origin_class.arel_table
      origin_joins = core_table.join(origin_table).on(origin_table[:id].eq(core_table[:origin_id]))

      where(core_table[:origin_type].eq(origin_class.to_s))
        .joins(origin_joins.join_sources)
    }

    # Finds Cores that have an origin_type of Service and are attached to the given host
    #
    # @method origin_service_host_id(host_id)
    # @scope Metasploit::Credential::Core
    # @param host_id [Integer] the host to look up
    # @return [ActiveRecord::Relation] scoped to that host
    scope :origin_service_host_id, lambda { |host_id|
      services_hosts.where(Mdm::Host.arel_table[:id].eq(host_id))
    }

    # Finds Cores that have an origin_type of Session that were collected from the given host
    #
    # @method origin_session_host_id(host_id)
    # @scope Metasploit::Credential::Core
    # @param host_id [Integer] the host to look up
    # @return [ActiveRecord::Relation] scoped to that host
    scope :origin_session_host_id, lambda { |host_id|
      sessions_hosts.where(Mdm::Host.arel_table[:id].eq(host_id))
    }

    # Adds a JOIN for the Service and Host that a Core with an Origin type of Service would have
    #
    # @method services_hosts
    # @scope Metasploit::Credential::Core
    # @return [ActiveRecord::Relation] with a JOIN on origin: services: hosts
    scope :services_hosts, lambda {
      core_table    = Metasploit::Credential::Core.arel_table
      service_table = Mdm::Service.arel_table
      host_table    = Mdm::Host.arel_table
      origin_table  = Metasploit::Credential::Origin::Service.arel_table

      origins(Metasploit::Credential::Origin::Service).joins(
        core_table.join(service_table).on(service_table[:id].eq(origin_table[:service_id])).join_sources,
        core_table.join(host_table).on(host_table[:id].eq(service_table[:host_id])).join_sources
      )
    }

    # Adds a JOIN for the Session and Host that a Core with an Origin type of Session would have
    #
    # @method sessions_hosts
    # @scope Metasploit::Credential::Core
    # @return [ActiveRecord::Relation] with a JOIN on origin: sessions: hosts
    scope :sessions_hosts, lambda {
      core_table    = Metasploit::Credential::Core.arel_table
      session_table = Mdm::Session.arel_table
      host_table    = Mdm::Host.arel_table
      origin_table  = Metasploit::Credential::Origin::Session.arel_table

      origins(Metasploit::Credential::Origin::Session).joins(
        core_table.join(session_table).on(session_table[:id].eq(origin_table[:session_id])).join_sources,
        core_table.join(host_table).on(host_table[:id].eq(session_table[:host_id])).join_sources
      )
    }

    # Finds all Cores that have been collected in some way from a Host
    #
    # @method originating_host_id
    # @scope Metasploit::Credential::Core
    # @param host_id [Integer] the host to look up
    # @return [ActiveRecord::Relation] that contains related Cores
    scope :originating_host_id, lambda { |host_id|
      # I'm sorry. I just didn't know what else to do.
      core_table = Metasploit::Credential::Core.arel_table
      where('metasploit_credential_cores.id IN (%s) OR metasploit_credential_cores.id IN (%s)' % [
        origin_session_host_id(host_id).select(core_table[:id]).to_sql,
        origin_service_host_id(host_id).select(core_table[:id]).to_sql
      ])
    }

    # Finds Cores that are attached to a given workspace
    #
    # @method workspace_id(id)
    # @scope Metasploit::Credential::Core
    # @param id [Integer] the workspace to look in
    # @return [ActiveRecord::Relation] scoped to the workspace
    scope :workspace_id, lambda { |id| where(workspace_id: id) }

  end
end