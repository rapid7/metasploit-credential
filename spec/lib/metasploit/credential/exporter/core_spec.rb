require 'spec_helper'

describe Metasploit::Credential::Exporter::Core do
  include_context 'Mdm::Workspace'

  let(:host){ FactoryGirl.create(:mdm_host, workspace: workspace)}
  let(:service){ FactoryGirl.create(:mdm_service, host:host) }
  let(:origin) { FactoryGirl.create(:metasploit_credential_origin_import) }
  let(:workspace){ FactoryGirl.create(:mdm_workspace) }
  let(:core){ FactoryGirl.create(:metasploit_credential_core, workspace: workspace, origin: origin) }

  subject(:core_exporter){ Metasploit::Credential::Exporter::Core.new(workspace: workspace) }

  before(:each) do
    origin.task = nil
  end

  describe "initialization" do
    it 'should raise an exception if initialized with an invalid mode' do
      expect{ Metasploit::Credential::Exporter::Core.new(mode: :fail_mode) }.to raise_error(RuntimeError)
    end

  end

  describe "#line_for_core" do

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

end