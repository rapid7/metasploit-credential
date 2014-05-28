FactoryGirl.define do
  factory :metasploit_credential_zip_importer_manifest_well_formed_compliant,
          class: Metasploit::Credential::Importer::CSV::Manifest  do

    origin { FactoryGirl.build :metasploit_credential_origin_import }
    data { generate :well_formed_csv_manifest_io }
  end

  factory :metasploit_credential_zip_importer_manifest_malformed,
          class: Metasploit::Credential::Importer::CSV::Manifest  do

    origin { FactoryGirl.build :metasploit_credential_origin_import }
    data { generate :malformed_csv_manifest_io }
  end

  sequence :well_formed_csv_manifest_io do |n|
    csv_string =<<-eos
username,ssh_key_file_name
fraggle,fraggle.pem
    eos
  end

  sequence :malformed_csv_manifest_io do |n|
    csv_string =<<-eos
bad_header1,bad_header2
fraggle,fraggle.pem
    eos
  end
end