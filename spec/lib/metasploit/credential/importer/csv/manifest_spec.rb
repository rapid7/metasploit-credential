require 'spec_helper'

describe Metasploit::Credential::Importer::CSV::Manifest do
  describe "#validation" do
    describe "with proper headers" do
      # it { should be_valid }
    end

    describe "without proper headers" do
      # it { should_not be_valid }
    end
  end

  describe "#key_data_from_file" do
    it 'should read the file and provide the contents as a string'
  end

  describe "#import" do
    it 'should create credentials from the manifest and keys'
  end
end