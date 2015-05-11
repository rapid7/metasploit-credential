require 'spec_helper'

describe Metasploit::Credential::Password, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

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
