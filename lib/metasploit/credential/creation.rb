
module Metasploit
  module Credential
    module Creation

      def active_db?
        ActiveRecord::Base.connected?
      end

      # This method is responsible for creation {Metasploit::Credential::Core} objects
      # and all sub-objects that it is dependent upon.
      #
      # @option opts [Symbol] :origin_type The Origin type we are trying to create
      # @option opts [String] :address The address of the {Mdm::Host} to link this Origin to
      # @option opts [Fixnum] :port The port number of the {Mdm::Service} to link this Origin to
      # @option opts [String] :service_name The service name to use for the {Mdm::Service}
      # @option opts [String] :protocol The protocol type of the {Mdm::Service} to link this Origin to
      # @option opts [String] :module_fullname The fullname of the Metasploit Module to link this Origin to
      # @option opts [Fixnum] :workspace_id The ID of the {Mdm::Workspace} to use for the {Mdm::Host}
      # @option opts [Fixnum] :task_id The ID of the {Mdm::Task} to link this Origin to
      # @option opts [String] :filename The filename of the file that was imported
      # @option opts [Fixnum] :user_id The ID of the {Mdm::User} to link this Origin to
      # @option opts [Fixnum] :session_id The ID of the {Mdm::Session} to link this Origin to
      # @option opts [String] :post_reference_name The reference name of the Metasploit Post module to link the origin to
      # @option opts [String] :private_data The actual data for the private (e.g. password, hash, key etc)
      # @option opts [Symbol] :private_type The type of {Metasploit::Credential::Private} to create
      # @option opts [String] :username The username to use for the {Metasploit::Credential::Public}
      # @raise [KeyError] if a required option is missing
      # @raise [ArgumentError] if an invalid :private_type is specified
      # @raise [ArgumentError] if an invalid :origin_type is specified
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Core]
      # @example Reporting a Bruteforced Credential
      #     create_credential(
      #       origin_type: :service,
      #       address: '192.168.1.100',
      #       port: 445,
      #       service_name: 'smb',
      #       protocol: 'tcp',
      #       module_fullname: 'auxiliary/scanner/smb/smb_login',
      #       workspace_id: myworkspace.id,
      #       private_data: 'password1',
      #       private_type: :password,
      #       username: 'Administrator'
      #     )
      def create_credential(opts={})
        return nil unless active_db?
        origin = create_credential_origin(opts)

        core_opts = {
            origin: origin,
            workspace_id: opts.fetch(:workspace_id)
        }

        if opts.has_key?(:realm_key) && opts.has_key?(:realm_value)
          core_opts[:realm] = create_credential_realm(opts)
        end

        if opts.has_key?(:private_type) && opts.has_key?(:private_data)
          core_opts[:private] = create_credential_private(opts)
        end

        if opts.has_key?(:username)
          core_opts[:public] = create_credential_public(opts)
        end

        create_credential_core(core_opts)
      end

      # This method is responsible for creating {Metasploit::Credential::Core} objects.
      #
      # @option opts [Metasploit::Credential::Origin] :origin The origin object to tie the core to
      # @option opts [Metasploit::Credential::Public] :public The {Metasploit::Credential::Public} component
      # @option opts [Metasploit::Credential::Private] :private The {Metasploit::Credential::Private} component
      # @option opts [Fixnum] :workspace_id The ID of the {Mdm::Workspace} to tie the Core to
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Core]
      def create_credential_core(opts={})
        return nil unless active_db?
        origin       = opts.fetch(:origin)
        workspace_id = opts.fetch(:workspace_id)

        if opts[:private]
          private_id = opts[:private].id
        else
          private_id = nil
        end

        if opts[:public]
          public_id = opts[:public].id
        else
          public_id = nil
        end

        if opts[:realm]
          realm_id = opts[:realm].id
        else
          realm_id = nil
        end

        core = Metasploit::Credential::Core.where(private_id: private_id, public_id: public_id, realm_id: realm_id, workspace_id: workspace_id).first_or_create
        if core.origin_id.nil?
          core.origin = origin
        end
        core.save!
        core
      end

      # This method is responsible for creating a {Metasploit::Credential::Login} object
      # which ties a {Metasploit::Credential::Core} to the {Mdm::Service} it is a valid
      # credential for.
      #
      # @option opts [String] :access_level The access level to assign to this login if we know it
      # @option opts [String] :address The address of the {Mdm::Host} to link this Login to
      # @option opts [DateTime] :last_attempted_at The last time this Login was attempted
      # @option opts [Metasploit::Credential::Core] :core The {Metasploit::Credential::Core} to link this login to
      # @option opts [Fixnum] :port The port number of the {Mdm::Service} to link this Login to
      # @option opts [String] :service_name The service name to use for the {Mdm::Service}
      # @option opts [String] :status The status for the Login object
      # @option opts [String] :protocol The protocol type of the {Mdm::Service} to link this Login to
      # @option opts [Fixnum] :workspace_id The ID of the {Mdm::Workspace} to use for the {Mdm::Host}
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Login]
      def create_credential_login(opts)
        return nil unless active_db?
        access_level       = opts.fetch(:access_level, nil)
        core               = opts.fetch(:core)
        last_attempted_at  = opts.fetch(:last_attempted_at, nil)
        status             = opts.fetch(:status)

        service_object = create_credential_service(opts)
        login_object = Metasploit::Credential::Login.where(core_id: core.id, service_id: service_object.id).first_or_initialize

        login_object.access_level      = access_level if access_level
        login_object.last_attempted_at = last_attempted_at if last_attempted_at
        login_object.status            = status
        login_object.save!
        login_object
      end

      # This method is responsible for creating the various Credential::Origin objects.
      # It takes a key for the Origin type and delegates to the correct sub-method.
      #
      # @option opts [Symbol] :origin_type The Origin type we are trying to create
      # @option opts [String] :address The address of the {Mdm::Host} to link this Origin to
      # @option opts [Fixnum] :port The port number of the {Mdm::Service} to link this Origin to
      # @option opts [String] :service_name The service name to use for the {Mdm::Service}
      # @option opts [String] :protocol The protocol type of the {Mdm::Service} to link this Origin to
      # @option opts [String] :module_fullname The fullname of the Metasploit Module to link this Origin to
      # @option opts [Fixnum] :workspace_id The ID of the {Mdm::Workspace} to use for the {Mdm::Host}
      # @option opts [Fixnum] :task_id The ID of the {Mdm::Task} to link this Origin to
      # @option opts [String] :filename The filename of the file that was imported
      # @option opts [Fixnum] :user_id The ID of the {Mdm::User} to link this Origin to
      # @option opts [Fixnum] :session_id The ID of the {Mdm::Session} to link this Origin to
      # @option opts [String] :post_reference_name The reference name of the Metasploit Post module to link the origin to
      # @raise [ArgumentError] if an invalid origin_type was provided
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Metasploit::Credential::Origin::Manual] if :origin_type was :manual
      # @return [Metasploit::Credential::Origin::Import] if :origin_type was :import
      # @return [Metasploit::Credential::Origin::Service] if :origin_type was :service
      # @return [Metasploit::Credential::Origin::Session] if :origin_type was :session
      def create_credential_origin(opts={})
        return nil unless active_db?
        case opts[:origin_type]
          when :import
            create_credential_origin_import(opts)
          when :manual
            create_credential_origin_manual(opts)
          when :service
            create_credential_origin_service(opts)
          when :session
            create_credential_origin_session(opts)
          else
            raise ArgumentError, "Unknown Origin Type #{opts[:origin_type]}"
        end
      end

      # This method is responsible for creating {Metasploit::Credential::Origin::Import} objects.
      #
      # @option opts [Fixnum] :task_id The ID of the {Mdm::Task} to link this Origin to
      # @option opts [String] :filename The filename of the file that was imported
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Metasploit::Credential::Origin::Manual] The created {Metasploit::Credential::Origin::Import} object
      def create_credential_origin_import(opts={})
        return nil unless active_db?
        task_id  = opts.fetch(:task_id)
        filename = opts.fetch(:filename)

        Metasploit::Credential::Origin::Import.where(filename: filename, task_id: task_id).first_or_create
      end

      # This method is responsible for creating {Metasploit::Credential::Origin::Manual} objects.
      #
      # @option opts [Fixnum] :user_id The ID of the {Mdm::User} to link this Origin to
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Metasploit::Credential::Origin::Manual] The created {Metasploit::Credential::Origin::Manual} object
      def create_credential_origin_manual(opts={})
        return nil unless active_db?
        user_id = opts.fetch(:user_id)

        Metasploit::Credential::Origin::Manual.where(user_id: user_id).first_or_create
      end

      # This method is responsible for creating {Metasploit::Credential::Origin::Service} objects.
      # If there is not a matching {Mdm::Host} it will create it. If there is not a matching
      # {Mdm::Service} it will create that too.
      #
      # @option opts [String] :address The address of the {Mdm::Host} to link this Origin to
      # @option opts [Fixnum] :port The port number of the {Mdm::Service} to link this Origin to
      # @option opts [String] :service_name The service name to use for the {Mdm::Service}
      # @option opts [String] :protocol The protocol type of the {Mdm::Service} to link this Origin to
      # @option opts [String] :module_fullname The fullname of the Metasploit Module to link this Origin to
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Metasploit::Credential::Origin::Service] The created {Metasploit::Credential::Origin::Service} object
      def create_credential_origin_service(opts={})
        return nil unless active_db?
        module_fullname  = opts.fetch(:module_fullname)

        service_object = create_credential_service(opts)

        Metasploit::Credential::Origin::Service.where(service_id: service_object.id, module_full_name: module_fullname).first_or_create
      end

      # This method is responsible for creating {Metasploit::Credential::Origin::Session} objects.
      #
      # @option opts [Fixnum] :session_id The ID of the {Mdm::Session} to link this Origin to
      # @option opts [String] :post_reference_name The reference name of the Metasploit Post module to link the origin to
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Metasploit::Credential::Origin::Session] The created {Metasploit::Credential::Origin::Session} object
      def create_credential_origin_session(opts={})
        return nil unless active_db?
        session_id           = opts.fetch(:session_id)
        post_reference_name  = opts.fetch(:post_reference_name)

        Metasploit::Credential::Origin::Session.where(session_id: session_id, post_reference_name: post_reference_name).first_or_create
      end

      # This method is responsible for the creation of {Metasploit::Credential::Private} objects.
      # It will create the correct subclass based on the type.
      #
      # @option opts [String] :private_data The actual data for the private (e.g. password, hash, key etc)
      # @option opts [Symbol] :private_type The type of {Metasploit::Credential::Private} to create
      # @raise [ArgumentError] if a valid type is not supplied
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Password] if the private_type was :password
      # @return [Metasploit::Credential::SSHKey] if the private_type was :ssh_key
      # @return [Metasploit::Credential::NTLMHash] if the private_type was :ntlm_hash
      # @return [Metasploit::Credential::NonreplayableHash] if the private_type was :nonreplayable_hash
      def create_credential_private(opts={})
        return nil unless active_db?
        private_data = opts.fetch(:private_data)
        private_type = opts.fetch(:private_type)

        case private_type
          when :password
            private_object = Metasploit::Credential::Password.where(data: private_data).first_or_create
          when :ssh_key
            private_object = Metasploit::Credential::SSHKey.where(data: private_data).first_or_create
          when :ntlm_hash
            private_object = Metasploit::Credential::NTLMHash.where(data: private_data).first_or_create
          when :nonreplayable_hash
            private_object = Metasploit::Credential::NonreplayableHash.where(data: private_data).first_or_create
          else
            raise ArgumentError, "Invalid Private type: #{private_type}"
        end
        private_object
      end

      # This method is responsible for the creation of {Metasploit::Credential::Public} objects.
      #
      # @option opts [String] :username The username to use for the {Metasploit::Credential::Public}
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Public]
      def create_credential_public(opts={})
        return nil unless active_db?
        username = opts.fetch(:username)

        Metasploit::Credential::Public.where(username: username).first_or_create
      end

      # This method is responsible for creating the {Metasploit::Credential::Realm} objects
      # that may be required.
      #
      # @option opts [String] :realm_key The type of Realm this is (e.g. 'Active Directory Domain')
      # @option opts [String] :realm_value The actual Realm name (e.g. contosso)
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no active database connection
      # @return [Metasploit::Credential::Realm] if it successfully creates or finds the object
      def create_credential_realm(opts={})
        return nil unless active_db?
        realm_key   = opts.fetch(:realm_key)
        realm_value = opts.fetch(:realm_value)

        Metasploit::Credential::Realm.where(key: realm_key, value: realm_value).first_or_create
      end



      # This method is responsible for creating a barebones {Mdm::Service} object
      # for use by Credential object creation.
      #
      # @option opts [String] :address The address of the {Mdm::Host}
      # @option opts [Fixnum] :port The port number of the {Mdm::Service}
      # @option opts [String] :service_name The service name to use for the {Mdm::Service}
      # @option opts [String] :protocol The protocol type of the {Mdm::Service}
      # @option opts [Fixnum] :workspace_id The ID of the {Mdm::Workspace} to use for the {Mdm::Host}
      # @raise [KeyError] if a required option is missing
      # @return [NilClass] if there is no connected database
      # @return [Mdm::Service]
      def create_credential_service(opts={})
        return nil unless active_db?
        address          = opts.fetch(:address)
        port             = opts.fetch(:port)
        service_name     = opts.fetch(:service_name)
        protocol         = opts.fetch(:protocol)
        workspace_id     = opts.fetch(:workspace_id)

        # Find or create the host object we need
        host_object    = Mdm::Host.where(address: address, workspace_id: workspace_id).first_or_create

        # Next we find or create the Service object we need
        service_object = Mdm::Service.where(host_id: host_object.id, port: port, proto: protocol).first_or_initialize
        service_object.name = service_name
        service_object.save!
        service_object
      end

    end
  end
end