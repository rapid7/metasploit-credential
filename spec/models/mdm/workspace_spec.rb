require 'spec_helper'

describe Mdm::Workspace do
  context 'associations' do
    it 'should have_many credential_cores', pending: 'metasploit-concern is needed to inject has_many :credential_cores on Mdm::Workspace' do
      should have_many(:credential_cores).class_name('Metasploit::Credential::Core').dependent(:destroy)
    end
  end
end