require 'spec_helper'

describe Metasploit::Credential::Importer::CSV::Manifest do
  include_context 'Mdm::Workspace'

  subject(:manifest_csv_importer){ FactoryGirl.build(:metasploit_credential_zip_importer_manifest)}

  # CSV objects are IOs
  after(:each) do
    manifest_csv_importer.csv_object.rewind
  end

  describe "#validation" do
    describe "with proper headers" do
      it { should be_valid }
    end

    describe "without proper headers" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/csv/base.attributes.data.incorrect_csv_headers')
      end

      before(:each) do
        manifest_csv_importer.data = FactoryGirl.generate :manifest_csv_bad_headers
      end

      it { should_not be_valid }

      it 'should report the error being incorrect headers' do
        manifest_csv_importer.valid?
        manifest_csv_importer.errors[:data].should include error
      end
    end

    describe "with an empty CSV" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/csv/base.attributes.data.empty_csv')
      end

      before(:each) do
        manifest_csv_importer.data = FactoryGirl.generate :empty_manifest_csv
      end

      it { should_not be_valid }

      it 'should report the error being empty CSV' do
        manifest_csv_importer.valid?
        manifest_csv_importer.errors[:data].should include error
      end
    end

    describe "with a malformed CSV" do
      let(:error) do
        I18n.translate!('activemodel.errors.models.metasploit/credential/importer/csv/base.attributes.data.malformed_csv')
      end

      before(:each) do
        manifest_csv_importer.data = FactoryGirl.generate :malformed_csv
      end

      it { should_not be_valid }

      it 'should report the error being malformed CSV' do
        manifest_csv_importer.valid?
        manifest_csv_importer.errors[:data].should include error
      end
    end

    describe "when accesssing without rewind" do
      before(:each) do
        manifest_csv_importer.csv_object.gets
      end

      it 'should raise a runtime error when attempting to validate' do
        expect{ manifest_csv_importer.valid? }.to raise_error(RuntimeError)
      end
    end
  end
end