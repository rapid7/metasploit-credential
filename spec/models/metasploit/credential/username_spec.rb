require 'spec_helper'

RSpec.describe Metasploit::Credential::Username, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it_should_behave_like 'timestamp database columns'

      it { is_expected.to have_db_column(:username).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:username).unique(true) }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
    it { is_expected.to allow_mass_assignment_of(:username) }
  end

  context 'validations' do
    context 'username' do
      it { is_expected.to validate_presence_of :username }
      it { is_expected.to validate_uniqueness_of :username }
    end
  end


end
