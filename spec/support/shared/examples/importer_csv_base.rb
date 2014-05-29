shared_examples_for 'base behavior for import CSV classes' do
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