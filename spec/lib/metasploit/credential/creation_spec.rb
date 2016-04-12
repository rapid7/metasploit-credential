RSpec.describe Metasploit::Credential::Creation do

  let(:dummy_class) {
    Class.new do
      include Metasploit::Credential::Creation
    end
  }

  let(:session) { FactoryGirl.create(:mdm_session) }

  let(:task) { FactoryGirl.create(:mdm_task, workspace: workspace)}

  let(:user) { FactoryGirl.create(:mdm_user)}

  let(:workspace) { FactoryGirl.create(:mdm_workspace) }

  subject(:test_object) { dummy_class.new }

  context '#create_cracked_credential' do
    let(:public) { FactoryGirl.create(:metasploit_credential_public) }
    let(:hash) { FactoryGirl.create(:metasploit_credential_nonreplayable_hash) }
    let(:origin) { FactoryGirl.create(:metasploit_credential_origin_manual) }
    let(:password) { "omgwtfbbq" }
    let(:realm) { FactoryGirl.create(:metasploit_credential_realm) }

    let!(:old_core) do
      FactoryGirl.create(:metasploit_credential_core, public: public, private: hash, realm: realm, workspace: workspace, origin: origin)
    end

    it 'creates a Core' do
      expect {
        test_object.create_cracked_credential(
            core_id: old_core,
            username: public.username,
            password: password
        )
      }.to change{Metasploit::Credential::Core.count}.by(1)
      expect(Metasploit::Credential::Private.last).to be_a Metasploit::Credential::Password
    end

    it 'replicates realm in new credential' do
      expect {
        test_object.create_cracked_credential(
          core_id: old_core.id,
          workspace_id: workspace.id,
          username: public.username,
          password: password
        )
      }.to change{Metasploit::Credential::Core.count}.by(1)
      expect(Metasploit::Credential::Core.last.realm).to eq(realm)
    end

    context 'when previous core has logins' do
      let(:host) { FactoryGirl.create(:mdm_host, workspace: workspace) }
      let(:service) { FactoryGirl.create(:mdm_service, host: host) }

      before do
        FactoryGirl.create(:metasploit_credential_login,
                           service: service,
                           core: old_core,
                           status: Metasploit::Model::Login::Status::UNTRIED
                          )
      end

      it 'creates mirrored Logins' do
        expect(old_core.logins.count).to eq(1)
        expect {
          test_object.create_cracked_credential(
            core_id: old_core.id,
            workspace_id: workspace.id,
            username: public.username,
            password: password
          )
        }.to change {
          Metasploit::Credential::Login.count
        }.by(1)
      end

    end

  end

  context '#create_credential_origin_import' do
    it 'creates a Metasploit::Credential::Origin object' do
      opts = {
          filename: "test_import.xml",
      }
      expect { test_object.create_credential_origin_import(opts)}.to change{Metasploit::Credential::Origin::Import.count}.by(1)
    end

    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_origin_import).to be_nil
    end

    context 'when called twice with the same options' do
      it 'does not create duplicate objects' do
        opts = {
            filename: "test_import.xml",
            task_id: task.id
        }
        test_object.create_credential_origin_import(opts)
        expect { test_object.create_credential_origin_import(opts)}.to_not change{Metasploit::Credential::Origin::Import.count}
      end
    end

    context 'when missing a required option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_origin_import(opts)}.to raise_error KeyError
      end
    end


  end

  context '#create_credential_origin_manual' do
    it 'creates a Metasploit::Credential::Origin object' do
      opts = {
          user_id: user.id
      }
      expect { test_object.create_credential_origin_manual(opts)}.to change{Metasploit::Credential::Origin::Manual.count}.by(1)
    end

    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_origin_manual).to be_nil
    end

    context 'when called twice with the same options' do
      it 'does not create duplicate objects' do
        opts = {
            user_id: user.id
        }
        test_object.create_credential_origin_manual(opts)
        expect { test_object.create_credential_origin_manual(opts)}.to_not change{Metasploit::Credential::Origin::Manual.count}
      end
    end

    context 'when missing an option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_origin_manual(opts)}.to raise_error KeyError
      end
    end
  end

  context "#create_credential_service" do
    let(:opts) do
      {
        address: '192.168.172.3',
        port: 445,
        service_name: 'smb',
        protocol: 'tcp',
        workspace_id: workspace.id
      }
    end

    it 'should create an Mdm::Service in state "open"' do
      service = test_object.create_credential_service opts
      expect(service.state).to eq("open")
    end
  end

  context '#create_credential_origin_service' do
    it 'creates a Metasploit::Credential::Origin object' do
      opts = {
          address: '192.168.172.3',
          port: 445,
          service_name: 'smb',
          protocol: 'tcp',
          module_fullname: 'auxiliary/scanner/smb/smb_login',
          workspace_id: workspace.id,
          origin_type: :service
      }
      expect { test_object.create_credential_origin_service(opts)}.to change{Metasploit::Credential::Origin::Service.count}.by(1)
    end

    it 'should return nil if there is no database connection' do
      my_module = test_object
      expect(my_module).to receive(:active_db?).and_return(false)
      expect(my_module.create_credential_origin_service).to be_nil
    end

    context 'when there is a matching host record' do
      it 'uses the existing host record' do
        opts = {
            address: '192.168.172.3',
            port: 445,
            service_name: 'smb',
            protocol: 'tcp',
            module_fullname: 'auxiliary/scanner/smb/smb_login',
            workspace_id: workspace.id,
            origin_type: :service
        }
        FactoryGirl.create(:mdm_host, address: opts[:address], workspace_id: opts[:workspace_id])
        expect { test_object.create_credential_origin_service(opts)}.to_not change{Mdm::Host.count}
      end
    end

    context 'when there is not a matching host record' do
      it 'create a new host record' do
        opts = {
            address: '192.168.172.3',
            port: 445,
            service_name: 'smb',
            protocol: 'tcp',
            module_fullname: 'auxiliary/scanner/smb/smb_login',
            workspace_id: workspace.id,
            origin_type: :service
        }
        expect { test_object.create_credential_origin_service(opts)}.to change{Mdm::Host.count}.by(1)
      end
    end

    context 'when there is a matching service record' do
      it 'uses the existing service record' do
        opts = {
            address: '192.168.172.3',
            port: 445,
            service_name: 'smb',
            protocol: 'tcp',
            module_fullname: 'auxiliary/scanner/smb/smb_login',
            workspace_id: workspace.id,
            origin_type: :service
        }
        host = FactoryGirl.create(:mdm_host, address: opts[:address], workspace_id: opts[:workspace_id])
        FactoryGirl.create(:mdm_service, host_id: host.id, port: opts[:port], proto: opts[:protocol])
        expect { test_object.create_credential_origin_service(opts)}.to_not change{Mdm::Service.count}
      end
    end

    context 'when there is no matching service record' do
      it 'creates a new service record' do
        opts = {
            address: '192.168.172.3',
            port: 445,
            service_name: 'smb',
            protocol: 'tcp',
            module_fullname: 'auxiliary/scanner/smb/smb_login',
            workspace_id: workspace.id,
            origin_type: :service
        }
        expect { test_object.create_credential_origin_service(opts)}.to change{Mdm::Service.count}.by(1)
      end
    end

    context 'when called twice with the same options' do
      it 'does not create duplicate objects' do
        opts = {
            address: '192.168.172.3',
            port: 445,
            service_name: 'smb',
            protocol: 'tcp',
            module_fullname: 'auxiliary/scanner/smb/smb_login',
            workspace_id: workspace.id,
            origin_type: :service
        }
        test_object.create_credential_origin_service(opts)
        expect { test_object.create_credential_origin_service(opts)}.to_not change{Metasploit::Credential::Origin::Service.count}
      end
    end

    context 'when missing an option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_origin_service(opts)}.to raise_error KeyError
      end
    end
  end

  context '#create_credential_origin_session' do
    it 'creates a Metasploit::Credential::Origin object' do
      opts = {
          post_reference_name: 'windows/gather/hashdump',
          session_id: session.id
      }
      expect { test_object.create_credential_origin_session(opts)}.to change{Metasploit::Credential::Origin::Session.count}.by(1)
    end

    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_origin_session).to be_nil
    end

    context 'when called twice with the same options' do
      it 'does not create duplicate objects' do
        opts = {
            post_reference_name: 'windows/gather/hashdump',
            session_id: session.id
        }
        test_object.create_credential_origin_session(opts)
        expect { test_object.create_credential_origin_session(opts)}.to_not change{Metasploit::Credential::Origin::Session.count}
      end
    end

    context 'when missing an option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_origin_session(opts) }.to raise_error KeyError
      end
    end
  end

  context '#create_credential_origin' do
    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_origin).to be_nil
    end

    it 'calls the correct method to create Origin::Import records' do
      opts = {
          filename: "test_import.xml",
          origin_type: :import,
          task_id: task.id
      }
      my_module = test_object
      expect(my_module).to receive(:create_credential_origin_import)
      my_module.create_credential_origin(opts)
    end

    it 'calls the correct method to create Origin::Manual records' do
      opts = {
          origin_type: :manual,
          user_id: user.id
      }
      my_module = test_object
      expect(my_module).to receive(:create_credential_origin_manual)
      my_module.create_credential_origin(opts)
    end

    it 'calls the correct method to create Origin::Service records' do
      opts = {
          address: '192.168.172.3',
          port: 445,
          service_name: 'smb',
          protocol: 'tcp',
          module_fullname: 'auxiliary/scanner/smb/smb_login',
          workspace_id: workspace.id,
          origin_type: :service
      }
      expect(test_object).to receive(:create_credential_origin_service)
      test_object.create_credential_origin(opts)
    end

    it 'calls the correct method to create Origin::Session records' do
      opts = {
          origin_type: :session,
          post_reference_name: 'windows/gather/hashdump',
          session_id: session.id
      }
      my_module = test_object
      expect(my_module).to receive(:create_credential_origin_session)
      my_module.create_credential_origin(opts)
    end

    it 'raises an exception if there is no origin type' do
      opts = {
          post_reference_name: 'windows/gather/hashdump',
          session_id: session.id
      }
      expect{test_object.create_credential_origin(opts)}.to raise_error ArgumentError, "Unknown Origin Type "
    end

    it 'raises an exception if given an invalid origin type' do
      opts = {
          origin_type: 'aaaaa',
          post_reference_name: 'windows/gather/hashdump',
          session_id: session.id
      }
      expect{test_object.create_credential_origin(opts)}.to raise_error ArgumentError, "Unknown Origin Type aaaaa"
    end
  end

  context '#create_credential_realm' do
    it 'creates a Metasploit::Credential::Realm object' do
      opts = {
          realm_key: 'Active Directory Domain',
          realm_value: 'contosso'
      }
      expect { test_object.create_credential_realm(opts)}.to change{Metasploit::Credential::Realm.count}.by(1)
    end

    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_realm).to be_nil
    end

    context 'when called twice with the same options' do
      it 'does not create duplicate objects' do
        opts = {
            realm_key: 'Active Directory Domain',
            realm_value: 'contosso'
        }
        test_object.create_credential_realm(opts)
        expect { test_object.create_credential_realm(opts)}.to_not change{Metasploit::Credential::Realm.count}
      end
    end

    context 'when missing an option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_origin_manual(opts)}.to raise_error KeyError
      end
    end
  end

  context '#create_credential_private' do
    it 'should return nil if there is no database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_private).to be_nil
    end

    context 'when missing an option' do
      it 'throws a KeyError' do
        opts = {}
        expect{ test_object.create_credential_private(opts)}.to raise_error KeyError
      end
    end

    context 'when :private_type is password' do
      it 'creates a Metasploit::Credential::Password' do
        opts = {
            private_data: 'password1',
            private_type: :password
        }
        expect{ test_object.create_credential_private(opts) }.to change{Metasploit::Credential::Password.count}.by(1)
      end
    end

    context 'when :private_type is sshkey' do
      it 'creates a Metasploit::Credential::SSHKey' do
        opts = {
            private_data: OpenSSL::PKey::RSA.generate(2048).to_s,
            private_type: :ssh_key
        }
        expect{ test_object.create_credential_private(opts) }.to change{Metasploit::Credential::SSHKey.count}.by(1)
      end
    end

    context 'when :private_type is ntlmhash' do
      it 'creates a Metasploit::Credential::NTLMHash' do
        opts = {
            private_data: Metasploit::Credential::NTLMHash.data_from_password_data('password1'),
            private_type: :ntlm_hash
        }
        expect{ test_object.create_credential_private(opts) }.to change{Metasploit::Credential::NTLMHash.count}.by(1)
      end
    end

    context 'when :private_type is nonreplayable_hash' do
      it 'creates a Metasploit::Credential::NonreplayableHash' do
        opts = {
            private_data: '10b222970537b97919db36ec757370d2',
            private_type: :nonreplayable_hash
        }
        expect{ test_object.create_credential_private(opts) }.to change{Metasploit::Credential::NonreplayableHash.count}.by(1)
      end
    end

    context 'when passed a blank string' do
      it 'creates a Metasploit::Credential::BlankPassword' do
        opts = {
          private_data: '',
          private_type: :password
        }
        expect(test_object.create_credential_private(opts)).to be_kind_of Metasploit::Credential::BlankPassword
      end
    end
  end

  context '#create_credential' do

    it 'associates the new Metasploit::Credential::Core with a task if passed' do
      opts = {
          origin_type: :manual,
           user_id: user.id,
          username: 'username',
          private_data: 'password',
          workspace_id: workspace.id,
          task_id: task.id
      }
      core = test_object.create_credential(opts)
      expect(core.tasks).to include(task)
    end

  end

  context '#create_credential_core' do
    let(:origin)    { FactoryGirl.create(:metasploit_credential_origin_service) }
    let(:public)    { FactoryGirl.create(:metasploit_credential_public)}
    let(:private)   { FactoryGirl.create(:metasploit_credential_password)}
    let(:realm)     { FactoryGirl.create(:metasploit_credential_realm)}
    let(:workspace) { origin.service.host.workspace }
    let(:task)      { FactoryGirl.create(:mdm_task, workspace: workspace) }

    it 'raises a KeyError if any required option is missing' do
      opts = {}
      expect{ test_object.create_credential_core(opts)}.to raise_error KeyError
    end

    it 'returns nil if there is no active database connection' do
      expect(test_object).to receive(:active_db?).and_return(false)
      expect(test_object.create_credential_core).to be_nil
    end

    it 'creates a Metasploit::Credential::Core' do
      opts = {
          origin: origin,
          public: public,
          private: private,
          realm: realm,
          workspace_id: workspace.id
      }
      expect{test_object.create_credential_core(opts)}.to change{Metasploit::Credential::Core.count}.by(1)
    end
    it 'associates the new Metasploit::Credential::Core with a task if passed' do
      opts = {
          origin: origin,
          public: public,
          private: private,
          realm: realm,
          workspace_id: workspace.id,
          task_id: task.id
      }
      core = test_object.create_credential_core(opts)
      expect(core.tasks).to include(task)
    end

  end

  context '#create_credential_login' do
    let(:workspace) { FactoryGirl.create(:mdm_workspace) }
    let(:service) { FactoryGirl.create(:mdm_service, host: FactoryGirl.create(:mdm_host, workspace: workspace)) }
    let(:task) { FactoryGirl.create(:mdm_task, workspace: workspace) }
    let(:credential_core) { FactoryGirl.create(:metasploit_credential_core_manual, workspace: workspace) }

    it 'creates a Metasploit::Credential::Login' do
      login_data = {
        address: service.host.address,
        port: service.port,
        service_name: service.name,
        protocol: service.proto,
        workspace_id: workspace.id,
        core: credential_core,
        last_attempted_at: DateTime.current,
        status: Metasploit::Model::Login::Status::SUCCESSFUL,
      }
      expect{test_object.create_credential_login(login_data)}.to change{Metasploit::Credential::Login.count}.by(1)
    end
    it "associates the Metasploit::Credential::Core with a task if passed" do
      login_data = {
        address: service.host.address,
        port: service.port,
        service_name: service.name,
        protocol: service.proto,
        workspace_id: workspace.id,
        task_id: task.id,
        core: credential_core,
        last_attempted_at: DateTime.current,
        status: Metasploit::Model::Login::Status::SUCCESSFUL,
      }
      login = test_object.create_credential_login(login_data)
      expect(login.tasks).to include(task)

    end

  end

  context '#invalidate_login' do

    context 'when an untried login exists' do
      let(:untried_login) { FactoryGirl.create(:metasploit_credential_login, status: Metasploit::Model::Login::Status::UNTRIED)}

      let(:opts) {{
        address: untried_login.service.host.address.to_s,
        port: untried_login.service.port,
        protocol: untried_login.service.proto,
        username: untried_login.core.public.username,
        private_data: untried_login.core.private.data,
        realm_key: untried_login.core.realm.try(:key),
        realm_value: untried_login.core.realm.try(:value),
        status: Metasploit::Model::Login::Status::INCORRECT
        }}

      it 'sets the supplied status on that login' do
        expect{ test_object.invalidate_login(opts) }.to change{untried_login.reload.status}.from(Metasploit::Model::Login::Status::UNTRIED).to(Metasploit::Model::Login::Status::INCORRECT)
      end

      it 'changes the last_attempted_at timestamp' do
        expect{ test_object.invalidate_login(opts) }.to change{untried_login.reload.last_attempted_at}
      end

      context 'when a login exists on the same service for a different credential' do
        let(:other_origin) {
          FactoryGirl.create(:metasploit_credential_origin_manual)
        }
        let(:other_core) {
          FactoryGirl.create(:metasploit_credential_core,
            workspace: untried_login.core.workspace,
            origin: other_origin
          )
        }
        let(:other_login) {
          FactoryGirl.create(:metasploit_credential_login,
            status: Metasploit::Model::Login::Status::UNTRIED,
            service: untried_login.service,
            core: other_core
          )
        }

        it 'updates the status on the correct login' do
          expect{ test_object.invalidate_login(opts) }.to_not change{other_login.reload.status}
        end
      end
    end
  end

end
