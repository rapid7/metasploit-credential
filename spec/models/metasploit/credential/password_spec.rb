require 'spec_helper'

describe Metasploit::Credential::Password do
  it { should be_a Metasploit::Credential::Private }

  context 'factories' do
    context 'metasploit_credential_password' do
      subject(:metasploit_credential_password) do
        FactoryGirl.build(:metasploit_credential_password)
      end

      it { should be_valid }
    end
  end
end
