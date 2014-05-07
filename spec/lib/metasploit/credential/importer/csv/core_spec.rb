require 'spec_helper'

describe Metasploit::Credential::Importer::Core do
  subject(:core_csv_importer)

  describe "validations" do
    context "without #file_path" do
      let(:error) do
        I18n.translate!('errors.messages.blank')
      end

      before(:each) do
        csv_importer.file_path = nil
        csv_importer.valid?
      end

      it { should include(error) }
    end
  end
end