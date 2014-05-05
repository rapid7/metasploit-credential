require 'spec_helper'

describe Metasploit::Credential::Login do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:core).class_name('Metasploit::Credential::Core') }
    it { should belong_to(:service).class_name('Mdm::Service')}
  end

  context 'callbacks' do
    context 'before_valiation' do
      context '#blank_to_nil' do
        include_context 'Mdm::Workspace'

        let(:login) do
          FactoryGirl.build(
              :metasploit_credential_login,
              access_level: written_access_level
          )
        end

        #
        # Callbacks
        #

        before(:each) do
          login.valid?
        end

        context '#access_level' do
          subject(:access_level) do
            login.access_level
          end

          context 'with blank' do
            let(:written_access_level) do
              ''
            end

            it { should be_nil }
          end

          context 'with nil' do
            let(:written_access_level) do
              nil
            end

            it { should be_nil }
          end

          context 'with present' do
            let(:written_access_level) do
              'admin'
            end

            it 'is not changed' do
              expect(access_level).to eq(written_access_level)
            end
          end
        end
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:access_level).of_type(:string).with_options(null: true) }
      it { should have_db_column(:last_attempted_at).of_type(:datetime).with_options(null: true) }
      it { should have_db_column(:status).of_type(:string).with_options(null: false) }

      it_should_behave_like 'timestamp database columns'

      context 'foreign keys' do
        it { should have_db_column(:core_id).of_type(:integer).with_options(null: false) }
        it { should have_db_column(:service_id).of_type(:integer).with_options(null: false) }
      end
    end

    context 'indices' do
      it { should have_db_index([:core_id, :service_id]).unique(true) }
      it { should have_db_index([:service_id, :core_id]).unique(true) }
    end
  end

  context 'factories' do
    include_context 'Mdm::Workspace'

    context 'metasploit_credential_login' do
      subject(:metasploit_credential_login) do
        FactoryGirl.build(:metasploit_credential_login)
      end

      it { should be_valid }

      context '#status' do
        subject(:metasploit_credential_login) do
          FactoryGirl.build(
              :metasploit_credential_login,
              status: status
          )
        end

        context 'with Metasploit::Credential::Login::Status::DENIED_ACCESS' do
          let(:status) do
            described_class::Status::DENIED_ACCESS
          end

          it { should be_valid }
        end

        context 'with Metasploit::Credential::Login::Status::DISABLED' do
          let(:status) do
            described_class::Status::DISABLED
          end

          it { should be_valid }
        end

        context 'with Metasploit::Credential::Login::Status::LOCKED_OUT' do
          let(:status) do
            described_class::Status::LOCKED_OUT
          end

          it { should be_valid }
        end

        context 'with Metasploit::Credential::Login::Status::SUCCESSFUL' do
          let(:status) do
            described_class::Status::SUCCESSFUL
          end

          it { should be_valid }
        end

        context 'with Metasploit::Credential::Login::Status::UNABLE_TO_CONNECT' do
          let(:status) do
            described_class::Status::UNABLE_TO_CONNECT
          end

          it { should be_valid }
        end

        context 'with Metasploit::Credential::Login::Status::UNTRIED' do
          let(:status) do
            described_class::Status::UNTRIED
          end

          it { should be_valid }
        end
      end
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:access_level) }
    it { should_not allow_mass_assignment_of(:core) }
    it { should_not allow_mass_assignment_of(:core_id) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should allow_mass_assignment_of(:last_attempted_at) }
    it { should_not allow_mass_assignment_of(:service) }
    it { should_not allow_mass_assignment_of(:service_id) }
    it { should allow_mass_assignment_of(:status) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  context 'validations' do
    it { should validate_presence_of :core }

    context 'with existent Metasploit::Credential::Login' do
      include_context 'Mdm::Workspace'

      before(:each) do
        # validate_uniqueness_of will use Metasploit::Credential::Login#service_id and not trigger service_id non-null
        # constraint.
        FactoryGirl.create(
            :metasploit_credential_login
        )
      end

      it { should validate_uniqueness_of(:core_id).scoped_to(:service_id) }
    end

    it { should validate_presence_of :service }
    it { should ensure_inclusion_of(:status).in_array(described_class::Status::ALL) }

    context '#consistent_last_attempted_at' do
      include_context 'Mdm::Workspace'

      subject(:last_attempted_at_errors) do
        login.errors[:last_attempted_at]
      end

      #
      # lets
      #

      let(:login) do
        FactoryGirl.build(
            :metasploit_credential_login,
            last_attempted_at: last_attempted_at,
            status: status
        )
      end

      #
      # Callbacks
      #

      before(:each) do
        login.valid?
      end

      context '#status' do
        context 'with Metasploit::Credential::Login::Status::UNTRIED' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/login.attributes.last_attempted_at.untried')
          end

          let(:status) do
            described_class::Status::UNTRIED
          end

          context 'with #last_attempted' do
            let(:last_attempted_at) do
              DateTime.now.utc
            end

            it { should include(error) }
          end

          context 'without #last_attempted' do
            let(:last_attempted_at) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without Metasploit::Credential::Login::Status::UNTRIED' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/login.attributes.last_attempted_at.tried')
          end

          let(:status) do
            statuses.sample
          end

          let(:statuses) do
            described_class::Status::ALL - [described_class::Status::UNTRIED]
          end

          context 'with #last_attempted' do
            let(:last_attempted_at) do
              DateTime.now.utc
            end

            it { should_not include(error) }
          end

          context 'without #last_attempted' do
            let(:last_attempted_at) do
              nil
            end

            it { should include(error) }
          end
        end
      end
    end

    context '#consistent_workspaces' do
      include_context 'Mdm::Workspace'

      subject(:workspace_errors) do
        login.errors[:base]
      end

      #
      # lets
      #

      let(:error) do
        I18n.translate!('activerecord.errors.models.metasploit/credential/login.attributes.base.inconsistent_workspaces')
      end

      let(:login) do
        FactoryGirl.build(
            :metasploit_credential_login,
            core: core,
            service: service
        )
      end

      #
      # Callbacks
      #

      before(:each) do
        login.valid?
      end

      context 'with #core' do
        let(:core) do
          FactoryGirl.build(:metasploit_credential_core)
        end

        context 'with Metasploit::Credential::Core#workspace' do
          context 'with #service' do
            let(:service) do
              FactoryGirl.build(
                  :mdm_service,
                  host: host
              )
            end

            context 'with Mdm::Service#host' do
              let(:host) do
                FactoryGirl.build(
                    :mdm_host,
                    workspace: workspace
                )
              end

              context 'with Mdm::Host#workspace' do
                context 'same as #workspace' do
                  let(:workspace) do
                    core.workspace
                  end

                  it { should_not include(error) }
                end

                context 'different than #workspace' do
                  let(:workspace) do
                    FactoryGirl.build(:mdm_workspace)
                  end

                  it { should include(error) }
                end
              end

              context 'without Mdm::Host#workspace' do
                let(:workspace) do
                  nil
                end

                it { should include(error) }
              end
            end

            context 'without Mdm::Service#host' do
              let(:host) do
                nil
              end

              it { should include(error) }
            end
          end

          context 'without #service' do
            let(:service) do
              nil
            end

            it { should include(error) }
          end
        end

        context 'without Metasploit::Credential::Core#workspace' do
          let(:core) do
            super().tap { |core|
              core.workspace = nil
            }
          end

          context 'with #service' do
            let(:service) do
              FactoryGirl.build(
                  :mdm_service,
                  host: host
              )
            end

            context 'with Mdm::Service#host' do
              let(:host) do
                FactoryGirl.build(
                    :mdm_host,
                    workspace: workspace
                )
              end

              context 'with Mdm::Host#workspace' do
                let(:workspace) do
                  FactoryGirl.build(:mdm_workspace)
                end

                it { should include(error) }
              end

              context 'without Mdm::Host#workspace' do
                let(:workspace) do
                  nil
                end

                it { should_not include(error) }
              end
            end

            context 'without Mdm::Service#host' do
              let(:host) do
                nil
              end

              it { should_not include(error) }
            end
          end

          context 'without #service' do
            let(:service) do
              nil
            end

            it { should_not include(error) }
          end
        end
      end

      context 'without #core' do
        let(:core) do
          nil
        end

        context 'with #service' do
          let(:service) do
            FactoryGirl.build(
                :mdm_service,
                host: host
            )
          end

          context 'with Mdm::Service#host' do
            let(:host) do
              FactoryGirl.build(
                  :mdm_host,
                  workspace: workspace
              )
            end

            context 'with Mdm::Host#workspace' do
              let(:workspace) do
                FactoryGirl.build(:mdm_workspace)
              end

              it { should include(error) }
            end

            context 'without Mdm::Host#workspace' do
              let(:workspace) do
                nil
              end

              it { should_not include(error) }
            end
          end

          context 'without Mdm::Service#host' do
            let(:host) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without #service' do
          let(:service) do
            nil
          end

          it { should_not include(error) }
        end
      end
    end
  end
end
