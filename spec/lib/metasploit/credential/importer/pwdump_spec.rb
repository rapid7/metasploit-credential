require 'spec_helper'

describe Metasploit::Credential::Importer::Pwdump do
  include_context 'Mdm::Workspace'

  let(:workspace) {FactoryGirl.create(:mdm_workspace)}
  let(:origin) { FactoryGirl.create(:metasploit_credential_origin_import) }

  subject(:pwdump_importer){ FactoryGirl.build(:metasploit_credential_importer_pwdump,
                                               workspace: workspace,
                                               origin: origin)}

  describe "validation" do
    it { should be_valid }

    describe "without a filename" do
      it 'should not be valid' do
        pwdump_importer.filename = nil
        pwdump_importer.should_not be_valid
      end
    end
  end

  describe "#blank_or_string" do
    context "with a blank string" do
      it 'should return empty string' do
        pwdump_importer.blank_or_string("").should == ""
      end
    end
    context "with a BLANK_CRED_STRING" do
      it 'should return empty string' do
        pwdump_importer.blank_or_string(Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING).should == ""
      end
    end

    context "with a JTR_NO_PASSWORD_STRING" do
      it 'should return empty string' do
        pwdump_importer.blank_or_string(Metasploit::Credential::Importer::Pwdump::JTR_NO_PASSWORD_STRING).should == ""
      end
    end

    context "with a present string" do
      it 'should return the string' do
        string = "mah-hard-passwerd"
        pwdump_importer.blank_or_string(string).should == string
      end
    end

    context "with the dehex flag" do
      it 'should dehex the string with the Metasploit::Credential::Text#dehex method' do
        string = "mah-hard-passwerd"
        Metasploit::Credential::Text.should_receive(:dehex).with string
        pwdump_importer.blank_or_string(string, true)
      end
    end
  end

  describe "#import!" do
    describe "creating Credential objects" do
      it 'should create the proper number of Cores' do
        expect{pwdump_importer.import!}.to change(Metasploit::Credential::Core, :count).from(0).to(5)
      end

      it 'should create the proper number of Logins' do
        expect{pwdump_importer.import!}.to change(Metasploit::Credential::Login, :count).from(0).to(5)
      end

      it 'should create the proper number of Publics' do
        expect{pwdump_importer.import!}.to change(Metasploit::Credential::Public, :count).from(0).to(2)
      end

      describe 'should create the proper number of Privates' do
        it 'should create 1 NTLM hash' do
          expect{pwdump_importer.import!}.to change(Metasploit::Credential::NTLMHash, :count).from(0).to(1)
        end

        it 'should create 2 NonreplayableHashes' do
          expect{pwdump_importer.import!}.to change(Metasploit::Credential::NonreplayableHash, :count).from(0).to(2)
        end

        it 'should create 2 Passwords' do
          expect{pwdump_importer.import!}.to change(Metasploit::Credential::Password, :count).from(0).to(2)
        end

        # Legacy files may have these lines when missing SSH key files
        it 'should not create a Private from a "Warning" line' do
          pwdump_importer.import!
          Metasploit::Credential::Private.where(data:'missing').should be_blank
        end
      end
    end

    describe "creating Host objects" do
      it 'should create the proper number of Hosts' do
        expect{pwdump_importer.import!}.to change(Mdm::Host, :count).from(0).to(2)
      end
    end

    describe "creating Service objects" do
      it 'should create the proper number of Services' do
        expect{pwdump_importer.import!}.to change(Mdm::Service, :count).from(0).to(2)
      end
    end

  end
  
end