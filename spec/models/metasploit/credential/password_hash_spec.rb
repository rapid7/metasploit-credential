require 'spec_helper'

describe Metasploit::Credential::PasswordHash do
  it { should be_a Metasploit::Credential::Private }

  context 'factories' do
    context 'metasploit_credential_password_hash' do
      subject(:metasploit_credential_password_hash) do
        FactoryGirl.build(:metasploit_credential_password_hash)
      end

      it { should be_valid }
    end
  end
end
