require 'spec_helper'

describe Metasploit::Credential::Exporter::Pwdump do
  include_context 'Mdm::Workspace'

  subject(:exporter){ Metasploit::Credential::Exporter::Pwdump.new}

  let(:public) { FactoryGirl.create(:metasploit_credential_username)}
  let(:core){ FactoryGirl.create :metasploit_credential_core, public: public }
  let(:login){ FactoryGirl.create(:metasploit_credential_login, core: core) }

  describe "formatting" do
    describe "associated Mdm::Service objects" do
      it 'should properly format the service information' do
        service = login.service
        exporter.format_service_for_login(login).should == "#{service.host.address}:#{service.port}/#{service.proto} (#{service.name})"
      end
    end

    describe "plaintext passwords" do
      let(:private){ FactoryGirl.build :metasploit_credential_password }

      before(:each) do
        core.private = private
      end

      it 'should have the proper formatting with extant data' do
        exporter.format_password(login).should == "#{login.core.public.username} #{login.core.private.data}"
      end

      it 'should have the proper formatting with a missing public' do
        login.core.public.username = ""
        exporter.format_password(login).should == "#{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING} #{login.core.private.data}"
      end

      it 'should have the proper formatting with a missing private' do
        login.core.private.data = ""
        exporter.format_password(login).should == "#{login.core.public.username} #{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING}"
      end
    end

    describe "non-replayable" do
      let(:private){ FactoryGirl.build :metasploit_credential_nonreplayable_hash }

      before(:each) do
        core.private = private
      end

      it 'should have the proper formatting with extant data' do
        exporter.format_nonreplayable_hash(login).should == "#{login.core.public.username}:#{login.core.private.data}:::"
      end

      it 'should have the proper formatting with a missing public' do
        login.core.public.username = ""
        exporter.format_nonreplayable_hash(login).should == "#{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING}:#{login.core.private.data}:::"
      end

      it 'should have the proper formatting with a missing private' do
        login.core.private.data = ""
        exporter.format_nonreplayable_hash(login).should == "#{login.core.public.username}:#{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING}:::"
      end
    end

    describe "NTLM" do
      let(:private){ FactoryGirl.build :metasploit_credential_ntlm_hash }

      before(:each) do
        core.private = private
      end

      it 'should have the proper formatting with extant data' do
        exporter.format_ntlm_hash(login).should == "#{login.core.public.username}:#{login.id}:#{login.core.private.data}:::"
      end

      it 'should have the proper formatting with a missing public' do
        login.core.public.username = ""
        exporter.format_ntlm_hash(login).should == "#{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING}:#{login.id}:#{login.core.private.data}:::"
      end

      it 'should have the proper formatting with a missing private' do
        login.core.private.data = ""
        exporter.format_ntlm_hash(login).should == "#{login.core.public.username}:#{login.id}:#{Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING}:::"
      end
    end

    describe "SMB net hashes" do
      describe "v1" do
        describe "netlm" do
          let(:private){ FactoryGirl.build :metasploit_credential_nonreplayable_hash, jtr_type: 'netlm' }

          before(:each) do
            core.private = private
          end

          it 'should have the proper formatting with extant data'
          it 'should have the proper formatting with a missing public'
          it 'should have the proper formatting with a missing private'
        end

        describe "netntlm" do
          let(:private){ FactoryGirl.build :metasploit_credential_nonreplayable_hash, jtr_type: 'netntlm' }

          before(:each) do
            core.private = private
          end

          it 'should have the proper formatting with extant data'
          it 'should have the proper formatting with a missing public'
          it 'should have the proper formatting with a missing private'
        end
      end

      describe "v2" do
        describe "netlmv2" do
          let(:private){ FactoryGirl.build :metasploit_credential_non_replayable_hash, jtr_type: 'netlmv2' }

          before(:each) do
            core.private = private
          end

          it 'should have the proper formatting with extant data'
          it 'should have the proper formatting with a missing public'
          it 'should have the proper formatting with a missing private'
        end

        describe "netntlmv2" do
          let(:private){ FactoryGirl.build :metasploit_credential_non_replayable_hash, jtr_type: 'netntlmv2' }

          before(:each) do
            core.private = private
          end

          it 'should have the proper formatting with extant data'
          it 'should have the proper formatting with a missing public'
          it 'should have the proper formatting with a missing private'
        end
      end
    end
  end
end