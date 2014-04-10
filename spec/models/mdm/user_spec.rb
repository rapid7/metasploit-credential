require 'spec_helper'

describe Mdm::User do
  context 'associations' do
    it 'should have_many manual_credential_origins', pending: 'metasploit-concern is needed to inject has_many :manual_credential_origins on Mdm::User' do
      should have_many(:manual_credential_origins).class_name('Metasploit::Credential::Origin::Manual').dependent(:destroy)
    end
  end
end