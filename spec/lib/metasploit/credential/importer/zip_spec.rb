require 'spec_helper'

describe Metasploit::Credential::Importer::Zip do
  include_context 'Mdm::Workspace'

  TEMP_PATH_GLOB   = "/tmp/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}*"

  subject(:zip_importer){ FactoryGirl.build :metasploit_credential_importer_zip }

  after(:each) do
    Dir.glob(TEMP_PATH_GLOB).each do |file_name|
      FileUtils.rm_rf(file_name)
    end
  end

  describe "validations" do
    DUMMY_ZIP_PATH = "/tmp/import-test-dummy.zip"

    context "when the zip file is not actually an archive" do
      subject(:zip_importer){ FactoryGirl.build :metasploit_credential_importer_zip,
                                                zip_file: File.open(DUMMY_ZIP_PATH, 'wb')}

      after(:each) do
        FileUtils.rm(DUMMY_ZIP_PATH)
      end

      it { should_not be_valid } 
    end

    context "when the zip file does not contain 'manifest.csv'" do
      subject(:zip_importer){ FactoryGirl.build :metasploit_credential_importer_zip_invalid_no_manifest}

      it { should_not be_valid }
    end
  end

  describe "#import!" do
    it 'should create Public credential objects for the usernames described in the manifest file' do
      expect{zip_importer.import!}.to change{Metasploit::Credential::Private.count}.from(0).to(5)
    end
  end

end