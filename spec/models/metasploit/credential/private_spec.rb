require 'spec_helper'

describe Metasploit::Credential::Private do
  context 'database' do
    context 'columns' do
      it_should_behave_like 'single table inheritance database columns'
      it_should_behave_like 'timestamp database columns'

      it { should have_db_column(:data).of_type(:text).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index([:type, :data]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_credential_private' do
      subject(:metasploit_credential_private) do
        FactoryGirl.build(:metasploit_credential_private)
      end

      it { should be_valid }
    end
  end

  context 'mass assignement security' do
    it { should_not allow_mass_assignment_of :created_at }
    it { should allow_mass_assignment_of :data }
    it { should_not allow_mass_assignment_of :id }
    it { should_not allow_mass_assignment_of :updated_at }
    it { should_not allow_mass_assignment_of :type }
  end

  context 'validations' do
    context 'data' do
      it { should validate_non_nilness_of :data }

      # `it { should validate_uniqueness_of(:data).scoped_to(:type) }` tries to use a NULL type, which isn't allowed, so
      # have to perform validation check manually
      context 'validates uniqueness of #data scoped to #type' do
        subject(:data_errors) do
          new_private.errors[:data]
        end

        #
        # lets
        #

        let(:error) do
          I18n.translate!(:'activerecord.errors.messages.taken')
        end

        let(:new_private) do
          FactoryGirl.build(
              :metasploit_credential_private,
              data: data,
              type: type
          )
        end

        #
        # let!s
        #

        let!(:existent_private) do
          FactoryGirl.create(
              :metasploit_credential_private
          )
        end

        #
        # Callbacks
        #

        before(:each) do
          new_private.valid?
        end

        context 'with same #data' do
          let(:data) do
            existent_private.data
          end

          context 'with same #type' do
            let(:type) do
              existent_private.type
            end

            it { should include(error) }
          end

          context 'without same #type' do
            let(:type) do
              FactoryGirl.generate :metasploit_credential_private_type
            end

            it { should_not include(error) }
          end
        end

        context 'without same #data' do
          let(:data) do
            FactoryGirl.generate :metasploit_credential_private_data
          end

          context 'with same #type' do
            let(:type) do
              existent_private.type
            end

            it { should_not include(error) }
          end

          context 'without same #type' do
            let(:type) do
              FactoryGirl.generate :metasploit_credential_private_type
            end

            it { should_not include(error) }
          end
        end
      end
    end
  end
end
