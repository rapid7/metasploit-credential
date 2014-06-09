require 'spec_helper'

describe Metasploit::Credential::Importer::Base do
  include_context 'Mdm::Workspace'

  describe "::import_zip_or_csv" do
    describe "when given a zip file" do
      it 'should work with the Zip importer'
    end

    describe "when given a CSV file" do
      it 'should work with the CSV Core importer'
    end

    describe "when given any other type of file" do
      it 'should not be valid'
    end
  end
end