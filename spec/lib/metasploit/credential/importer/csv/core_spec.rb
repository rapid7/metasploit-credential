require 'spec_helper'

describe Metasploit::Credential::Importer::CSV::Core do
  subject(:core_csv_importer){FactoryGirl.build(:metasploit_credential_core_importer)}

  describe "validations" do
    describe "with well-formed CSV data" do
      describe "with a compliant header" do
        it { should be_valid }
      end
    end
  end
end
