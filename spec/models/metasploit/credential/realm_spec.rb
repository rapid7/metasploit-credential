require 'spec_helper'

describe Metasploit::Credential::Realm do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it { should have_db_column(:key).of_type(:string).with_options(null: false) }
      it { should have_db_column(:value).of_type(:string).with_options(null: false) }

      it_should_behave_like 'timestamp database columns'
    end

    context 'indices' do
      it { should have_db_index([:key, :value]).unique(true) }
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

    context 'metasplit_credential_oracle_system_identifier' do
      subject(:metasploit_credential_oracle_system_identifier) do
        FactoryGirl.build(:metasploit_credential_oracle_system_identifier)
      end

      it { should be_valid }

      its(:key) { should == described_class::Key::ORACLE_SYSTEM_IDENTIFIER }
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
    context 'on #key' do
      it { should ensure_inclusion_of(:key).in_array(described_class::Key::ALL) }
      it { should validate_presence_of :key }
    end

    context 'on #value' do
      it { should validate_presence_of :value }

      # key cannot be NULL so `validate_uniqueness_of(:value).scoped_to(:key)` does not work because it tries a NULL
      # key
      context 'validates uniqueness of #value scoped to #key' do
        subject(:value_errors) do
          new_realm.errors[:value]
        end

        #
        # lets
        #

        let(:error) do
          I18n.translate!('activerecord.errors.messages.taken')
        end

        let(:new_realm) do
          FactoryGirl.build(
              :metasploit_credential_realm,
              key: key,
              value: value
          )
        end

        #
        # let!s
        #

        let!(:existent_realm) do
          FactoryGirl.create(
              :metasploit_credential_realm
          )
        end

        #
        # Callback
        #

        before(:each) do
          new_realm.valid?
        end

        context 'with same #key' do
          let(:key) do
            existent_realm.key
          end

          context 'with same #value' do
            let(:value) do
              existent_realm.value
            end

            it { should include(error) }
          end

          context 'without same #value' do
            let(:value) do
              FactoryGirl.generate :metasploit_credential_realm_value
            end

            it { should_not include(error) }
          end
        end

        context 'without same #key' do
          let(:key) do
            FactoryGirl.generate :metasploit_credential_realm_key
          end

          context 'with same #value' do
            let(:value) do
              existent_realm.value
            end

            it { should_not include(error) }
          end

          context 'without same #value' do
            let(:value) do
              FactoryGirl.generate :metasploit_credential_realm_value
            end

            it { should_not include(error) }
          end
        end
      end
    end
  end
end
