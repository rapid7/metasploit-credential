require 'spec_helper'

describe Metasploit::Credential::Exporter::Core do
  include_context 'Mdm::Workspace'
  include_context 'export objects'


  subject(:core_exporter){ Metasploit::Credential::Exporter::Core.new(workspace: workspace) }

  before(:each) do
    origin.task = nil
  end

  #
  # Clean up generated files/paths
  #
  after(:each) do
    Dir.glob("#{Dir.tmpdir}/metasploit*").each {|d| FileUtils.rm_rf d}
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
        key_path = core_exporter.path_for_key(core)
        Pathname.new(key_path).basename.to_s.should == key_path_basename_string
      end
    end

    describe "when the argument is a Login" do
      it 'should be formed from the Public#username and the Private#id' do
        key_path = core_exporter.path_for_key(login)
        Pathname.new(key_path).basename.to_s.should == key_path_basename_string
      end
    end
  end

  describe "#line_for_core" do
    it 'should produce values in the proper order' do
      core_exporter.line_for_core(core).values.should == [core.public.username, core.private.type,
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

    it 'should produce a hash with the name of the private type' do
      result_hash = core_exporter.line_for_core(core)
      result_hash[:private_type].should == core.private.type
    end
  end

  describe "#line_for_login" do
    let(:login){ FactoryGirl.create(:metasploit_credential_login, core: core, service: service) }

    it 'should produce values in the proper order' do
      core_exporter.line_for_login(login).values.should == [core.public.username, core.private.type,
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
      result_hash[:private_type].should == login.core.private.type
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
    describe "in LOGIN_MODE" do
      before(:each) do
        core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::LOGIN_MODE
      end

      describe "when whitelist_ids is present" do
        before(:each) do
          core_exporter.stub(:whitelist_ids).and_return([login1.id])
        end

        it 'should contain only those objects whose IDs are in the whitelist' do
          core_exporter.data.should_not include(login2)
        end
      end

      describe "when whitelist_ids is blank" do
        it 'should be the same as #export_data' do
          core_exporter.data.should == core_exporter.export_data
        end
      end
    end

    describe "in CORE_MODE" do
      before(:each) do
        core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::CORE_MODE
      end

      describe "when whitelist_ids is present" do
        before(:each) do
          core_exporter.stub(:whitelist_ids).and_return([core1.id])
        end

        it 'should contain only those objects whose IDs are in the whitelist' do
          core_exporter.data.should_not include(core2)
        end
      end

      describe "when whitelist_ids is blank" do
        it 'should be the same as #export_data' do
          core_exporter.data.should == core_exporter.export_data
        end
      end
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

  describe "generation" do
    describe "#render_manifest_and_output_keys" do
      describe "in CORE_MODE" do
        before(:each) do
          core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::CORE_MODE
          core_exporter.render_manifest_output_and_keys
          path = core_exporter.output_final_directory_path + '/' + Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME

          @core_publics            = []
          @core_private_data       = []
          @core_private_types      = []
          @core_realm_keys         = []
          @core_realm_values       = []

          CSV.new(File.open(path), headers:true).each do |row|
            @core_publics            << row['username']
            @core_private_data       << row['private_data']
            @core_private_types      << row['private_type']
            @core_realm_keys         << row['realm_key']
            @core_realm_values       << row['realm_value']
          end
        end

        it 'should contain the Public#username for all Core objects' do
          @core_publics.should include(core1.public.username)
          @core_publics.should include(core2.public.username)
        end

        it 'should contain the Private#type for all Core objects' do
          @core_private_types.should include(core1.private.type)
          @core_private_types.should include(core2.private.type)
        end

        it 'should contain the Private#data for all Core objects' do
          @core_private_data.should include(core1.private.data)
          @core_private_data.should include(core2.private.data)
        end

        it 'should contain the Realm#key for all Core objects' do
          @core_realm_keys.should include(core1.realm.key)
          @core_realm_keys.should include(core2.realm.key)
        end

        it 'should contain the Realm#value for all Core objects' do
          @core_realm_values.should include(core1.realm.value)
          @core_realm_values.should include(core2.realm.value)
        end
      end

      describe "in LOGIN_MODE" do
        before(:each) do
          core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::LOGIN_MODE
          core_exporter.render_manifest_output_and_keys
          path = core_exporter.output_final_directory_path + '/' + Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME

          @login_publics            = []
          @login_private_data       = []
          @login_private_types      = []
          @login_realm_keys         = []
          @login_realm_values       = []
          @login_host_addresses     = []
          @login_service_ports      = []
          @login_service_names      = []
          @login_service_protocols  = []

          CSV.new(File.open(path), headers:true).each do |row|
            @login_publics            << row['username']
            @login_private_data       << row['private_data']
            @login_private_types      << row['private_type']
            @login_realm_keys         << row['realm_key']
            @login_realm_values       << row['realm_value']
            @login_host_addresses     << row['host_address']
            @login_service_ports      << row['service_port']
            @login_service_names      << row['service_name']
            @login_service_protocols  << row['service_protocol']
          end
        end


        it 'should contain the Public#username for all Login objects' do
          @login_publics.should include(login1.core.public.username)
          @login_publics.should include(login2.core.public.username)
        end

        it 'should contain the Private#type for all Login objects' do
          @login_private_types.should include(login1.core.private.type)
          @login_private_types.should include(login2.core.private.type)
        end

        it 'should contain the Private#data for all Login objects' do
          @login_private_data.should include(login1.core.private.data)
          @login_private_data.should include(login2.core.private.data)
        end

        it 'should contain the Realm#key for all Login objects' do
          @login_realm_keys.should include(login1.core.realm.key)
          @login_realm_keys.should include(login2.core.realm.key)
        end

        it 'should contain the Realm#value for all Login objects' do
          @login_realm_values.should include(login1.core.realm.value)
          @login_realm_values.should include(login2.core.realm.value)
        end

        it 'should contain the associated Mdm::Host#address for all Login objects' do
          @login_host_addresses.should include(login1.service.host.address)
          @login_host_addresses.should include(login2.service.host.address)
        end

        it 'should contain the associated Mdm::Service#port (stringified) for all Login objects' do
          @login_service_ports.should include(login1.service.port.to_s)
          @login_service_ports.should include(login2.service.port.to_s)
        end

        it 'should contain the associated Mdm::Service#name for all Login objects' do
          @login_service_names.should include(login1.service.name)
          @login_service_names.should include(login2.service.name)
        end

        it 'should contain the associated Mdm::Service#proto for all Login objects' do
          @login_service_protocols.should include(login1.service.proto)
          @login_service_protocols.should include(login2.service.proto)
        end
      end
    end

    describe "#rendered_zip" do
      describe "when there are no SSH keys in the dataset" do
        before(:each) do
          core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::CORE_MODE
          core_exporter.render_manifest_output_and_keys
          core_exporter.render_zip
        end

        it 'should contain the manifest file' do
          manifest_entry = nil
          Zip::File.open(core_exporter.output_zipfile_path) do |zip_file|
            manifest_entry = zip_file.glob(Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME).first
          end
          manifest_entry.should_not be_blank
        end

        it 'should not contain a keys directory' do
          keys_entry = nil
          Zip::File.open(core_exporter.output_zipfile_path) do |zip_file|
            keys_entry = zip_file.glob(Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME).first
          end
          keys_entry.should be_blank
        end
      end

      describe "when there ARE SSH keys in the dataset" do
        let(:private_with_key){ FactoryGirl.create(:metasploit_credential_ssh_key)}
        let!(:core_with_key){ FactoryGirl.create(:metasploit_credential_core,
                                                 origin: origin,
                                                 public: public1,
                                                 private: private_with_key,
                                                 workspace: workspace)}

        before(:each) do
          core_exporter.stub(:mode).and_return Metasploit::Credential::Exporter::Core::CORE_MODE
          core_exporter.render_manifest_output_and_keys
          core_exporter.render_zip
        end

        it 'should contain the manifest file' do
          manifest_entry = nil
          Zip::File.open(core_exporter.output_zipfile_path) do |zip_file|
            manifest_entry = zip_file.glob(Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME).first
          end
          manifest_entry.should_not be_blank
        end

        it 'should contain a keys directory' do
          keys_entry = nil
          Zip::File.open(core_exporter.output_zipfile_path) do |zip_file|
            keys_entry = zip_file.glob(Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME).first
          end
          keys_entry.should_not be_blank
        end

        describe "the keys directory" do
          before(:each) do
            @key_entries = nil
            Zip::File.open(core_exporter.output_zipfile_path) do |zip_file|
              @key_entries = zip_file.glob("#{Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME}/*")
            end
          end

          it 'should contain a key for each SSH private in the export' do
            @key_entries.size.should == core_exporter.data.select{ |d| d.private.type == Metasploit::Credential::SSHKey.name }.size
          end

          it 'should contain key files named with Public#username and Private#id for each Core that uses an SSHKey' do
            key_names = @key_entries.map{ |e| e.to_s.gsub("#{Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME}/", '') }
            key_names.should include("#{core_with_key.public.username}-#{core_with_key.private.id}")
          end

        end
      end
    end
  end
end