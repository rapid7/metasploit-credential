require 'spec_helper'

describe Metasploit::Credential::Importer::Zip do
  include_context 'Mdm::Workspace'
  include_context 'metasploit_credential_importer_zip_file'

  subject(:zip_importer){ FactoryGirl.build :metasploit_credential_importer_zip }

  describe "validations" do
    DUMMY_ZIP_PATH = "/tmp/import-test-dummy.zip"

    context "when the zip file contains a keys directory and a manifest CSV" do
      it { should be_valid }
    end

    context "when the zip file is not actually an archive" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/zip.attributes.data.malformed_archive')
      end

      before(:each) do
        File.open(DUMMY_ZIP_PATH, 'wb')
        zip_importer.data = File.open(DUMMY_ZIP_PATH, 'r')
      end

      after(:each) do
        FileUtils.rm(DUMMY_ZIP_PATH)
      end

      it { should_not be_valid }

      it 'should show the proper error message' do
        zip_importer.valid?
        zip_importer.errors[:data].should include error
      end
    end

    context "when the zip file does not contain a manifest CSV" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/zip.attributes.data.missing_manifest')
      end

      before(:each) do
        zip_importer.data = FactoryGirl.generate :metasploit_credential_importer_zip_file_without_manifest
      end

      it { should_not be_valid }

      it 'should show the proper error message' do
        zip_importer.valid?
        zip_importer.errors[:data].should include error
      end
    end

    context "when the zip file does not contain keys" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/zip.attributes.data.missing_keys')
      end

      before(:each) do
        zip_importer.data = FactoryGirl.generate :metasploit_credential_importer_zip_file_invalid_no_keys
      end

      it { should_not be_valid }

      it 'should show the proper error message' do
        zip_importer.valid?
        zip_importer.errors[:data].should include error
      end
    end
  end

  describe "#import!" do
    it 'should create Public credential objects for the usernames described in the manifest file' do
      expect{zip_importer.import!}.to change{Metasploit::Credential::Private.count}.from(0).to(5)
    end
  end

end