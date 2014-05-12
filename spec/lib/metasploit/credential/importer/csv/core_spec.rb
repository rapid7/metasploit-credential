require 'spec_helper'

describe Metasploit::Credential::Importer::CSV::Core do
  include_context 'Mdm::Workspace'

  subject(:core_csv_importer){FactoryGirl.build(:metasploit_credential_core_importer_well_formed_compliant)}

  # CSV objects are IOs
  after(:each) do
    core_csv_importer.csv_object.rewind
  end

  # TODO: factor this stuff out when it belongs in a shared example set covering the Base class
  describe "BASE BEHAVIOR - MIGRATE" do
    describe "validations" do
      describe "with well-formed CSV data" do
        describe "with a compliant header" do
          subject(:core_csv_importer){FactoryGirl.build(:metasploit_credential_core_importer_well_formed_compliant)}

          it { should be_valid }
        end

        describe "with a non-compliant header" do
          subject(:core_csv_importer){FactoryGirl.build(:metasploit_credential_core_importer_well_formed_non_compliant)}

          it { should_not be_valid }
          it 'should show the proper error message'
        end

        describe "with a malformed CSV" do
          it 'should not be valid'
          it 'should show the proper error message'
        end

        describe "with an empty CSV" do
          it 'should not be valid'
          it 'should show the proper error message'
        end
      end
    end
  end


  describe "#import!" do
    context "public" do
      context "when it is already in the DB" do
        # Contains 3 unique Publics
        let(:stored_public){ core_csv_importer.csv_object.gets; core_csv_importer.csv_object.first['username'] }

        before(:each) do
          Metasploit::Credential::Public.create!(username: stored_public)
          core_csv_importer.csv_object.rewind
        end

        it 'should not create a new Metasploit::Credential::Public for that object' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Public, :count).from(1).to(3)
        end
      end

      context "when it is not in the DB" do
        it 'should create a new Metasploit::Credential::Public for each unique Public in the import' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Public, :count).from(0).to(3)
        end
      end
    end

    context "private" do
      context "when it is already in the DB" do
        # Contains 3 unique Privates
        let(:stored_private_row){ core_csv_importer.csv_object.gets; core_csv_importer.csv_object.first }
        let(:private_class){ stored_private_row['private_type'].constantize }

        before(:each) do
          private_cred      = private_class.new
          private_cred.data = stored_private_row['private_data']
          private_cred.save!
          core_csv_importer.csv_object.rewind
        end

        it 'should not create a new Metasploit::Credential::Private for that object' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Private, :count).from(1).to(3)
        end

      end

      context "when it is not in the DB" do
        it 'should create a new Metasploit::Credential::Private for each unique Private in the import' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Private, :count).from(0).to(3)
        end
      end
    end

    context "realm" do
      context "when it is already in the DB" do
        # Contains 2 unique Realms
        let(:stored_realm_row){ core_csv_importer.csv_object.gets; core_csv_importer.csv_object.first }

        before(:each) do
          Metasploit::Credential::Realm.create(key: stored_realm_row['realm_key'],
                                               value: stored_realm_row['realm_value'])
        end

        it 'should create only Realms that do not exist in the DB' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Realm, :count).from(1).to(2)
        end
      end

      context "when it is not in the DB" do
        it 'should create only Realms that do not exist in the DB' do
          expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Realm, :count).from(0).to(2)
        end
      end
    end

    context "core" do
      it 'should create a Core object for each row in the DB' do
        expect{ core_csv_importer.import! }.to change(Metasploit::Credential::Core, :count).from(0).to(3)
      end
    end
  end

end
