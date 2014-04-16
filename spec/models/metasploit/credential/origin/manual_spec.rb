require 'spec_helper'

describe Metasploit::Credential::Origin::Manual do
  context 'associations' do
    it { should have_many(:cores).class_name('Metasploit::Credential::Core').dependent(:destroy) }
    it { should belong_to(:user).class_name('Mdm::User') }
  end

  context 'database' do
    context 'columns' do
      context 'foreign keys' do
        it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
      end

      it_should_behave_like 'timestamp database columns'
    end

    context 'indices' do
      context 'foreign keys' do
        it { should have_db_index(:user_id) }
      end
    end
  end

  context 'factories' do
    context 'metasploit_credential_origin_manual' do
      subject(:metasploit_credential_origin_manual) do
        FactoryGirl.build(:metasploit_credential_origin_manual)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :user }
  end
end
