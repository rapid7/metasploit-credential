require 'spec_helper'

describe Metasploit::Credential::Importer::Multi do
  TEMP_PATH_GLOB   = "/tmp/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}*"
  UNSUPPORTED_FILE = "bad.txt"


  after(:all) do
    tmp_path = Dir.glob("#{Dir.tmpdir}/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}*").first
    FileUtils.rm_rf(tmp_path)
  end

  describe "validation" do
    describe "when given a file that is not a zip or a CSV" do
      let(:unsupported_file){ File.open("#{Dir.tmpdir}/#{UNSUPPORTED_FILE}", 'wb') }
      subject(:multi_importer){ Metasploit::Credential::Importer::Multi.new unsupported_file}

      it { should_not be_valid }
    end

    context "when given zip file" do
      let(:supported_file){ FactoryGirl.generate :metasploit_credential_importer_zip_file }
      subject(:multi_importer){ Metasploit::Credential::Importer::Multi.new supported_file}

      it { should be_valid }
    end
  end
end