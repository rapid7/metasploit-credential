require 'spec_helper'

describe Mdm::Workspace do
  context 'associations' do
    it { should have_many(:core_credentials).class_name('Metasploit::Credential::Core').dependent(:destroy) }
  end
end