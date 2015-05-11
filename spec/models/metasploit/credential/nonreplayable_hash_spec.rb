require 'spec_helper'

RSpec.describe Metasploit::Credential::NonreplayableHash, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it { should be_a Metasploit::Credential::PasswordHash }

  context 'factories' do
    context 'metasploit_credential_nonreplayable_hash' do
      subject(:metasploit_credential_nonreplayable_hash) do
        FactoryGirl.build(:metasploit_credential_nonreplayable_hash)
      end

      it { should be_valid }
    end
  end
end
