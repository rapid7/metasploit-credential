require 'spec_helper'

RSpec.describe Mdm::Task, type: :model do
  context 'associations' do
    it { should have_many(:import_credential_origins).class_name('Metasploit::Credential::Origin::Import').dependent(:destroy) }
    it { should have_and_belong_to_many(:credential_cores).class_name('Metasploit::Credential::Core') }
    it { should have_and_belong_to_many(:credential_logins).class_name('Metasploit::Credential::Login') }
  end
end