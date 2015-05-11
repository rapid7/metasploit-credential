require 'spec_helper'

describe Mdm::Session, type: :model do
  context 'associations' do
    it { should have_many(:credential_origins).class_name('Metasploit::Credential::Origin::Session').dependent(:destroy) }
  end
end