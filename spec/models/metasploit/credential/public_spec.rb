require 'spec_helper'

describe Metasploit::Credential::Public do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it_should_behave_like 'timestamp database columns'

      it { should have_db_column(:username).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index(:username).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_credential_public' do
      subject(:metasploit_credential_public) do
        FactoryGirl.build(:metasploit_credential_public)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
    it { should allow_mass_assignment_of(:username) }
  end

  context 'validations' do
    context 'username' do
      it { should validate_presence_of :username }
      it { should validate_uniqueness_of :username }
    end
  end

  context 'search' do
    let(:base_class) {
      described_class
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute',
                            :username,
                            type: :string
    end
  end

end
