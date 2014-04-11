require 'spec_helper'

describe Metasploit::Credential::Origin::Session do
  context 'associations' do
    it { should belong_to(:session).class_name('Mdm::Session') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:post_reference_name).of_type(:text).with_options(null: false) }

      it_should_behave_like 'timestamp database columns'

      context 'foreign keys' do
        it { should have_db_column(:session_id).of_type(:integer).with_options(null: false) }
      end
    end

    context 'columns' do
      it { should have_db_index([:session_id, :post_reference_name]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_credential_origin_session' do
      include_context 'Mdm::Workspace'

      subject(:metasploit_credential_origin_session) do
        FactoryGirl.build(:metasploit_credential_origin_session)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should allow_mass_assignment_of(:post_reference_name) }
    it { should_not allow_mass_assignment_of(:session) }
    it { should_not allow_mass_assignment_of(:session_id) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  context 'validations' do
    context 'post_reference_name' do
      include_context 'Mdm::Workspace'

      before(:each) do
        FactoryGirl.create(:metasploit_credential_origin_session)
      end

      it { should validate_presence_of :post_reference_name }
      it { should validate_uniqueness_of(:post_reference_name).scoped_to(:session_id) }
    end

    it { should validate_presence_of :session }
  end
end
