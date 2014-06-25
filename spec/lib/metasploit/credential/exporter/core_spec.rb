require 'spec_helper'

describe Metasploit::Credential::Exporter::Core do
  include_context 'Mdm::Workspace'

  let(:host){ FactoryGirl.create(:mdm_host, workspace: workspace)}
  let(:service){ FactoryGirl.create(:mdm_service, host:host) }
  let(:origin) { FactoryGirl.create(:metasploit_credential_origin_import) }
  let(:workspace){ FactoryGirl.create(:mdm_workspace) }
  let(:core){ FactoryGirl.create(:metasploit_credential_core, workspace: workspace, origin: origin) }
  let(:login){ FactoryGirl.create(:metasploit_credential_login, service: service, core:core) }

  subject(:core_exporter){ Metasploit::Credential::Exporter::Core.new(workspace: workspace) }

  before(:each) do
    origin.task = nil
  end

  describe "initialization" do
    it 'should raise an exception if initialized with an invalid mode' do
      expect{ Metasploit::Credential::Exporter::Core.new(mode: :fail_mode) }.to raise_error(RuntimeError)
    end

    it 'should be in LOGIN_MODE by default' do
      core_exporter.mode.should == Metasploit::Credential::Exporter::Core::LOGIN_MODE
    end
  end

  describe "#header_line" do
    describe "in LOGIN_MODE" do
      it 'should have the proper headers' do
        core_exporter.header_line.should == Metasploit::Credential::Importer::Core::VALID_LONG_CSV_HEADERS.push(:host_address, :service_port, :service_name, :service_protocol)
      end
    end

    describe "in CORE_MODE" do
      it 'should have the proper headers' do
        core_exporter.header_line.should == Metasploit::Credential::Importer::Core::VALID_LONG_CSV_HEADERS
      end
    end
  end

  describe "#key_path" do
    let(:key_path_basename_string){ "#{core.public.username}-#{core.private.id}" }

    describe "when the argument is a Core" do
      it 'should be formed from the Public#username and the Private#id' do
        key_path = core_exporter.key_path(core)
        Pathname.new(key_path).basename.to_s.should == key_path_basename_string
      end
    end

    describe "when the argument is a Login" do
      it 'should be formed from the Public#username and the Private#id' do
        key_path = core_exporter.key_path(login)
        Pathname.new(key_path).basename.to_s.should == key_path_basename_string
      end
    end
  end

  describe "#line_for_core" do
    it 'should produce values in the proper order' do
      core_exporter.line_for_core(core).values.should == [core.public.username, core.private.type.demodulize,
                                                          core.private.data, core.realm.key, core.realm.value]
    end

    it 'should produce a hash with the public username' do
      result_hash = core_exporter.line_for_core(core)
      result_hash[:username].should == core.public.username
    end

    it 'should produce a hash with the private data' do
      result_hash = core_exporter.line_for_core(core)
      result_hash[:private_data].should == core.private.data
    end

    it 'should produce a hash with the demodulized name of the  private type' do
      result_hash = core_exporter.line_for_core(core)
      result_hash[:private_type].should == core.private.type.demodulize
    end
  end

  describe "#line_for_login" do
    let(:login){ FactoryGirl.create(:metasploit_credential_login, core: core, service: service) }

    it 'should produce values in the proper order' do
      core_exporter.line_for_login(login).values.should == [core.public.username, core.private.type.demodulize,
                                                            core.private.data, core.realm.key, core.realm.value,
                                                            login.service.host.address, login.service.port,
                                                            login.service.name, login.service.proto]
    end

    it 'should produce a hash with the service host address' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:host_address].should == login.service.host.address
    end

    it 'should produce a hash with the service port' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:service_port].should == login.service.port
    end

    it 'should produce a hash with the service name' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:service_name].should == login.service.name
    end

    it 'should produce a hash with the service protocol' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:service_protocol].should == login.service.proto
    end

    it 'should produce a hash with the public information' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:username].should == login.core.public.username
    end

    it 'should produce a hash with the private data' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:private_data].should == login.core.private.data
    end

    it 'should produce a hash with the demodulized name of the  private type' do
      result_hash = core_exporter.line_for_login(login)
      result_hash[:private_type].should == login.core.private.type.demodulize
    end
  end

  describe "#output" do
    it 'should be a writable File' do
      file_stat = core_exporter.output.stat
      file_stat.should be_writable
    end

    it 'should not be opened in binmode' do
      core_exporter.output.should_not be_binmode
    end
  end

  describe "#output_directory_path" do
    it 'should be in the platform-agnostic temp directory' do
      core_exporter.output_final_directory_path.should include(Dir.tmpdir)
    end

    it 'should have the set export prefix' do
      core_exporter.output_final_directory_path.should include(Metasploit::Credential::Exporter::Core::TEMP_ZIP_PATH_PREFIX)
    end

    describe "uniqueness for export" do
      let(:path_fragment){ "export-#{Time.now.to_s}" }

      before(:each) do
        core_exporter.stub(:output_final_subdirectory_name).and_return(path_fragment)
      end

      it 'should include a special time-stamped directory to contain the export data being staged' do
        core_exporter.output_final_directory_path.should include(core_exporter.output_final_subdirectory_name)
      end
    end
  end

  describe "#data" do
    describe "when whitelist_ids is present" do
      it 'should contain only those objects whose IDs are in the whitelist' 
    end

    describe "when whitelist_ids is blank" do
      it 'should be the same as #export_data'
    end
  end

  describe "#export_data" do
    describe "in CORE_MODE" do
      before(:each) do
        core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::CORE_MODE
      end

      it 'should grab data using the proper scope' do
        Metasploit::Credential::Core.should_receive(:workspace_id).with(core_exporter.workspace.id)
        core_exporter.export_data
      end
    end

    describe "in LOGIN_MODE" do
      before(:each) do
        core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::LOGIN_MODE
      end

      it 'should grab data using the proper scope' do
        Metasploit::Credential::Login.should_receive(:in_workspace_including_hosts_and_services).with(core_exporter.workspace)
        core_exporter.export_data
      end
    end
  end

  describe "#render_manifest_and_output_keys" do
    describe "when there are no SSH keys in the dataset" do

    end

    describe "when there ARE SSH keys in the dataset" do

    end
  end

end