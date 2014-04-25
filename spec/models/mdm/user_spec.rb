require 'spec_helper'

describe Mdm::User do
  context 'associations' do
    it { should have_many(:credential_origins).class_name('Metasploit::Credential::Origin::Manual').dependent(:destroy) }
  end
end