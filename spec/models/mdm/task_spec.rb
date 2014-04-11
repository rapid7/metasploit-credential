require 'spec_helper'

describe Mdm::Task do
  context 'associations' do
    it 'should have_many :import_credential_origins', pending: 'metasploit-concern available to patch Mdm::Task' do
      it { should have_many(:import_credential_origins).class_name('Metasploit::Credential::Origin::Import').dependent(:destroy) }
    end
  end
end