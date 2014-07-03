require 'spec_helper'

describe Mdm::Task do
  context 'associations' do
    it { should have_many(:import_credential_origins).class_name('Metasploit::Credential::Origin::Import').dependent(:destroy) }
    it { should have_and_belong_to_many(:credential_cores).class_name('Metasploit::Credential::Core') }
  end
end