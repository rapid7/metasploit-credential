require 'spec_helper'

describe Metasploit::Credential::Importer::Zip do

  describe "validations" do
    context "when the zip file is not actually an archive" do
      it { should_not be_valid } 
    end

    context "when the zip file does not contain 'manifest.csv'" do
      it { should_not be_valid }
    end
  end
end