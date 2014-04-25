require 'spec_helper'

describe Metasploit::Credential::ReplayableHash do
  it { should be_a Metasploit::Credential::PasswordHash }

  context 'factories' do
    context 'metasploit_credential_replayable_hash' do
      subject(:metasploit_credential_replayable_hash) do
        FactoryGirl.build(:metasploit_credential_replayable_hash)
      end

      it { should be_valid }
    end
  end
end
