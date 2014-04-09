require 'spec_helper'

describe Metasploit::Credential::NonreplayableHash do
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
