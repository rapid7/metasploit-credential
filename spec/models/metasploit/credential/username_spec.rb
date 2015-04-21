require 'spec_helper'

describe Metasploit::Credential::Username do
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

  context 'validations' do
    context 'username' do
      it { should validate_presence_of :username }
      it { should validate_uniqueness_of :username }
    end
  end


end
