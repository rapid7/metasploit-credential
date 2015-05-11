require 'spec_helper'

RSpec.describe Metasploit::Credential::Origin::Import, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:cores).class_name('Metasploit::Credential::Core').dependent(:destroy) }
    it { is_expected.to belong_to(:task).class_name('Mdm::Task') }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:filename).of_type(:text).with_options(null: false) }

      it_should_behave_like 'timestamp database columns'

      context 'foreign keys' do
        it { is_expected.to have_db_column(:task_id).of_type(:integer) }
      end
    end

    context 'indices' do
      context 'foreign keys' do
        it { is_expected.to have_db_index(:task_id) }
      end
    end
  end

  context 'factories' do
    include_context 'Mdm::Workspace'

    subject(:metasploit_credential_origin_import) do
      FactoryGirl.build(:metasploit_credential_origin_import)
    end

    it { is_expected.to be_valid }
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of :created_at }
    it { is_expected.to allow_mass_assignment_of :filename }
    it { should_not allow_mass_assignment_of :task }
    it { should_not allow_mass_assignment_of :task_id }
    it { should_not allow_mass_assignment_of :updated_at }
  end
end
