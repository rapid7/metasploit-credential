require 'spec_helper'

describe Metasploit::Credential::Importer::CSV::Manifest do
  include_context 'Mdm::Workspace'

  describe "#validation" do
    describe "with proper headers" do
      subject(:well_formed_manifest){ FactoryGirl.build(:metasploit_credential_zip_importer_manifest_well_formed_compliant)}

      it { should be_valid }
    end

    describe "without proper headers" do
      subject(:malformed_manifest){ FactoryGirl.build(:metasploit_credential_zip_importer_manifest_malformed)}

      it { should_not be_valid }
    end
  end

  describe "#key_data_from_file" do
    it 'should read the file and provide the contents as a string'
  end

  describe "#import" do
    it 'should create credentials from the manifest and keys'
  end
end