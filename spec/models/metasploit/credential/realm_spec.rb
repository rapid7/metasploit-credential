require 'spec_helper'

describe Metasploit::Credential::Realm do
  context 'database' do
    context 'columns' do
      it { should have_db_column(:key).of_type(:string).with_options(null: false) }
      it { should have_db_column(:value).of_type(:string).with_options(null: false) }

      it_should_behave_like 'timestamp database columns'
    end
  end

  context 'factories' do
    context 'metasploit_credential_active_directory_domain' do
      subject(:metasploit_credential_active_directory_domain) do
        FactoryGirl.build(:metasploit_credential_active_directory_domain)
      end

      it { should be_valid }

      its(:key) { should == described_class::Key::ACTIVE_DIRECTORY_DOMAIN }
    end

    context 'metasploit_credential_postgresql_database' do
      subject(:metasploit_credential_postgresql_database) do
        FactoryGirl.build(:metasploit_credential_postgresql_database)
      end

      it { should be_valid }

      its(:key) { should == described_class::Key::POSTGRESQL_DATABASE }
    end

    context 'metasploit_credential_realm' do
      subject(:metasploit_credential_realm) do
        FactoryGirl.build(:metasploit_credential_realm)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:key) }
    it { should allow_mass_assignment_of(:value) }
  end

  context 'validations' do
    it { should validate_presence_of :key }
    it { should validate_presence_of :value }
  end
end
