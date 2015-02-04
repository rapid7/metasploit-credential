require 'spec_helper'

describe Metasploit::Credential::BlankUsername do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it_should_behave_like 'timestamp database columns'

      it { should have_db_column(:username).of_type(:string).with_options(null: false) }
      it { should have_db_column(:type).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index(:username).unique(true) }
    end
  end

end
