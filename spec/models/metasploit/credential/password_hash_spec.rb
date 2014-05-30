require 'spec_helper'

describe Metasploit::Credential::PasswordHash do
  it_should_behave_like 'Metasploit::Concern.run'

  it { should be_a Metasploit::Credential::Private }

  context 'factories' do
    context 'metasploit_credential_password_hash' do
      subject(:metasploit_credential_password_hash) do
        FactoryGirl.build(:metasploit_credential_password_hash)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :data }
  end
end
