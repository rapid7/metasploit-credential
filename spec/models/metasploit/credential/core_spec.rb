require 'spec_helper'

describe Metasploit::Credential::Core do
  include_context 'Mdm::Workspace'

  subject(:core) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should have_many(:logins).class_name('Metasploit::Credential::Login').dependent(:destroy) }
    it { should belong_to(:origin) }
    it { should belong_to(:private).class_name('Metasploit::Credential::Private') }
    it { should belong_to(:public).class_name('Metasploit::Credential::Public') }
    it { should belong_to(:realm).class_name('Metasploit::Credential::Realm') }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'database' do
    context 'columns' do
      context 'foreign keys' do
        context 'polymorphic origin' do
          it { should have_db_column(:origin_id).of_type(:integer).with_options(null: false) }
          it { should have_db_column(:origin_type).of_type(:string).with_options(null: false) }
        end

        it { should have_db_column(:private_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:public_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:realm_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:workspace_id).of_type(:integer).with_options(null: false) }
      end

      it_should_behave_like 'timestamp database columns'
    end

    context 'indices' do
      context 'foreign keys' do
        it { should have_db_index([:origin_type, :origin_id]) }
        it { should have_db_index(:private_id) }
        it { should have_db_index(:public_id) }
        it { should have_db_index(:realm_id) }
        it { should have_db_index(:workspace_id) }
      end
    end
  end

  context 'scopes' do

    context '.workspace_id' do
      let(:query) { described_class.workspace_id(workspace_id) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core)
      end

      context 'when given a valid workspace id' do
        let(:workspace_id) { metasploit_credential_core.workspace_id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid workspace id' do
        let(:workspace_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.login_host_id' do
      let(:query) { described_class.login_host_id(host_id) }
      let(:login) { FactoryGirl.create(:metasploit_credential_login) }
      subject(:metasploit_credential_core) { login.core }

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.logins.first.service.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.origin_service_host_id' do
      let(:query) { described_class.origin_service_host_id(host_id) }
      let(:workspace) { FactoryGirl.create(:mdm_workspace) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core_service)
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.origin.service.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.origin_session_host_id' do
      let(:query) { described_class.origin_session_host_id(host_id) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core_session)
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.origin.session.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.originating_host_id' do
      let(:query) { described_class.originating_host_id(host_id) }

      let!(:metasploit_credential_core_session) do
        FactoryGirl.create(:metasploit_credential_core_session)
      end

      let!(:metasploit_credential_core_service) do
        FactoryGirl.create(:metasploit_credential_core_service)
      end

      before do
        metasploit_credential_core_session.origin.session.host = metasploit_credential_core_service.origin.service.host
        metasploit_credential_core_session.origin.session.save
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core_session.origin.session.host.id }

        it 'returns an ActiveRecord::Relation' do
          expect(query).to be_an ActiveRecord::Relation
        end

        it 'returns the correct Cores' do
          expect(query).to match_array [metasploit_credential_core_session, metasploit_credential_core_service]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

  end

  context 'factories' do
    context 'metasploit_credential_core' do
      subject(:metasploit_credential_core) do
        FactoryGirl.build(:metasploit_credential_core)
      end

      let(:origin) do
        metasploit_credential_core.origin
      end

      it { should be_valid }

      context 'with origin_factory' do
        subject(:metasploit_credential_core) do
          FactoryGirl.build(
              :metasploit_credential_core,
              origin_factory: origin_factory
          )
        end

        context ':metasploit_credential_origin_import' do
          let(:origin_factory) do
            :metasploit_credential_origin_import
          end

          it { should be_valid }

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it 'is origin.task.workspace' do
              expect(workspace).not_to be_nil
              expect(workspace).to eq(origin.task.workspace)
            end
          end
        end

        context ':metasploit_credential_origin_manual' do
          let(:origin_factory) do
            :metasploit_credential_origin_manual
          end

          it { should be_valid }

          context '#origin' do
            subject(:origin) do
              metasploit_credential_core.origin
            end

            it { should be_a Metasploit::Credential::Origin::Manual }
          end

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it { should_not be_nil }
          end
        end

        context ':metasploit_credential_origin_service' do
          let(:origin_factory) do
            :metasploit_credential_origin_service
          end

          it { should be_valid }

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it 'is origin.service.host.workspace' do
              expect(workspace).not_to be_nil
              expect(workspace).to eq(origin.service.host.workspace)
            end
          end
        end

        context ':metasploit_credential_origin_session' do
          let(:origin_factory) do
            :metasploit_credential_origin_session
          end

          it { should be_valid }

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it 'is origin.session.host.workspace' do
              expect(workspace).not_to be_nil
              expect(workspace).to eq(origin.session.host.workspace)
            end
          end
        end
      end
    end

    context 'metasploit_credential_core_import' do
      subject(:metasploit_credential_core_import) do
        FactoryGirl.build(:metasploit_credential_core_import)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_import.workspace
        end

        let(:origin) do
          metasploit_credential_core_import.origin
        end

        it 'is origin.task.workspace' do
          expect(workspace).not_to be_nil
          expect(workspace).to eq(origin.task.workspace)
        end
      end
    end

    context 'metasploit_credential_core_manual' do
      subject(:metasploit_credential_core_manual) do
        FactoryGirl.build(:metasploit_credential_core_manual)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_manual.workspace
        end

        it { should_not be_nil }
      end
    end

    context 'metasploit_credential_core_service' do
      subject(:metasploit_credential_core_service) do
        FactoryGirl.build(:metasploit_credential_core_service)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_service.workspace
        end

        let(:origin) do
          metasploit_credential_core_service.origin
        end

        it 'is origin.service.host.workspace' do
          expect(workspace).not_to be_nil
          expect(workspace).to eq(origin.service.host.workspace)
        end
      end
    end

    context 'metasploit_credential_core_session' do
      subject(:metasploit_credential_core_session) do
        FactoryGirl.build(:metasploit_credential_core_session)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_session.workspace
        end

        let(:origin) do
          metasploit_credential_core_session.origin
        end

        it 'is origin.session.host.workspace' do
          expect(workspace).not_to be_nil
          expect(workspace).to eq(origin.session.host.workspace)
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :origin }
    it { should validate_presence_of :workspace }

    context '#consistent_workspaces' do
      subject(:workspace_errors) do
        core.errors[:workspace]
      end

      #
      # lets
      #

      let(:core) do
        FactoryGirl.build(
            :metasploit_credential_core,
            origin: origin,
            workspace: workspace
        )
      end

      let(:workspace) do
        FactoryGirl.create(:mdm_workspace)
      end

      #
      # Callbacks
      #

      before(:each) do
        core.valid?
      end

      context '#origin' do
        context 'with Metasploit::Credential::Origin::Import' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_task_workspace')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_import,
                task: task
            )
          end

          context 'with Metasploit::Credential::Origin::Import#task' do
            let(:task) do
              FactoryGirl.build(
                  :mdm_task,
                  workspace: task_workspace
              )
            end

            context 'with Mdm::Task#workspace' do
              context 'same as #workspace' do
                let(:task_workspace) do
                  workspace
                end

                it { should_not include error }
              end

              context 'different than #workspace' do
                let(:task_workspace) do
                  FactoryGirl.create(:mdm_workspace)
                end

                it { should include(error) }
              end
            end

            context 'without Mdm::Task#workspace' do
              let(:task_workspace) do
                nil
              end

              it { should include error }
            end
          end

          context 'without Metasploit::Credential::Origin::Import#task' do
            let(:task) do
              nil
            end

            it { should include(error) }
          end
        end

        context 'with Metasploit::Credential::Origin::Manual' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_user_workspaces')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_manual,
                user: user
            )
          end

          context 'with Metasploit::Credential::Origin::Manual#user' do
            let(:user) do
              FactoryGirl.build(
                  :mdm_user,
                  admin: admin
              )
            end

            context 'with Mdm::User#admin' do
              let(:admin) do
                true
              end

              it { should_not include error }
            end

            context 'without Mdm::User#admin' do
              let(:admin) do
                false
              end

              context 'with #workspace in Mdm::User#workspaces' do
                let(:user) do
                  super().tap { |user|
                    user.workspaces << workspace
                  }
                end

                context 'with persisted' do
                  let(:user) do
                    super().tap { |user|
                      user.save!
                    }
                  end

                  it { should_not include error }
                end

                context 'without persisted' do
                  it { should_not include error }
                end
              end

              context 'without #workspace in Mdm::User#workspaces' do
                it { should include error }
              end
            end
          end

          context 'without Metasploit::Credential::Origin::Manual#user' do
            let(:user) do
              nil
            end

            it { should include error }
          end
        end

        context 'with Metasploit::Credential::Origin::Service' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_service_host_workspace')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_service,
                service: service
            )
          end

          context 'with Metasploit::Credential::Origin::Service#service' do
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
                    workspace: host_workspace
                )
              end

              context 'same as #workspace' do
                let(:host_workspace) do
                  workspace
                end

                it { should_not include error }
              end

              context 'different than #workspace' do
                let(:host_workspace) do
                  FactoryGirl.create(:mdm_workspace)
                end

                it { should include error }
              end
            end

            context 'without Mdm::Service#host' do
              let(:host) do
                nil
              end

              it { should include error }
            end
          end

          context 'without Metasploit::Credential::Origin::Service#service' do
            let(:service) do
              nil
            end

            it { should include error }
          end
        end

        context 'with Metasploit::Credential::Origin::Session' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_session_host_workspace')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_session,
                session: session
            )
          end

          context 'with Metasploit::Credential::Origin::Session#session' do
            let(:session) do
              FactoryGirl.build(
                  :mdm_session,
                  host: host
              )
            end

            context 'with Mdm::Session#host' do
              let(:host) do
                FactoryGirl.build(
                    :mdm_host,
                    workspace: host_workspace
                )
              end

              context 'with Mdm::Host#workspace' do
                context 'same as #workspace' do
                  let(:host_workspace) do
                    workspace
                  end

                  it { should_not include error }
                end

                context 'different than #workspace' do
                  let(:host_workspace) do
                    FactoryGirl.create(:mdm_workspace)
                  end

                  it { should include error }
                end
              end

              context 'without Mdm::Host#workspace' do
                let(:host_workspace) do
                  nil
                end

                it { should include error }
              end
            end

            context 'without Mdm::Session#host' do
              let(:host) do
                nil
              end

              it { should include error }
            end
          end

          context 'without Metasploit::Credential::Origin::Session#session' do
            let(:session) do
              nil
            end

            it { should include error }
          end
        end
      end
    end

    context '#minimum_presence' do
      subject(:base_errors) do
        core.errors[:base]
      end

      #
      # lets
      #

      let(:core) do
        FactoryGirl.build(
            :metasploit_credential_core,
            private: private,
            public: public,
            realm: realm
        )
      end

      let(:error) do
        I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.base.minimum_presence')
      end

      #
      # Callbacks
      #

      before(:each) do
        core.valid?
      end

      context 'with #private' do
        let(:private) do
          FactoryGirl.build(private_factory)
        end

        let(:private_factory) do
          FactoryGirl.generate :metasploit_credential_core_private_factory
        end

        context 'with #public' do
          let(:public) do
            FactoryGirl.build(:metasploit_credential_public)
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without #public' do
          let(:public) do
            nil
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end
      end

      context 'without #private' do
        let(:private) do
          nil
        end

        context 'with #public' do
          let(:public) do
            FactoryGirl.build(:metasploit_credential_public)
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without #public' do
          let(:public) do
            nil
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should include(error) }
          end
        end
      end
    end
  end
end
