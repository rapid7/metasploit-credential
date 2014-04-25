require 'spec_helper'

describe Mdm::Service do
  context 'associations' do
    it { should have_many(:credential_origins).class_name('Metasploit::Credential::Origin::Service').dependent(:destroy) }
    it { should have_many(:logins).class_name('Metasploit::Credential::Login').dependent(:destroy) }
  end
end