require 'spec_helper'

describe Metasploit::Credential::Importer::Multi do
  include_context 'Mdm::Workspace'
  include_context 'metasploit_credential_importer_zip_file'

  UNSUPPORTED_FILE = 'bad.txt'

  let(:import_origin){ FactoryGirl.create :metasploit_credential_origin_import }

  describe "validation" do
    describe "when given a file that is not a zip or a CSV" do
      let(:unsupported_file){ File.open("#{Dir.tmpdir}/#{UNSUPPORTED_FILE}", 'wb') }
      subject(:multi_importer){ Metasploit::Credential::Importer::Multi.new(data: unsupported_file, origin: import_origin)}

      it { should_not be_valid }
    end

    context "when given zip file" do
      let(:supported_file){ FactoryGirl.generate :metasploit_credential_importer_zip_file }
      subject(:multi_importer){ Metasploit::Credential::Importer::Multi.new(data: supported_file, origin: import_origin)}

      it { should be_valid }
    end
  end
end