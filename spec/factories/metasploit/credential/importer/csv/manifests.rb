FactoryGirl.define do
  factory :metasploit_credential_zip_importer_manifest,
          class: Metasploit::Credential::Importer::CSV::Manifest  do

    origin { FactoryGirl.build :metasploit_credential_origin_import }
    data { generate :well_formed_manifest_csv }
  end


  sequence :well_formed_manifest_csv do |n|
    csv_string =<<-eos
username,ssh_key_file_name
fraggle,fraggle.pem
    eos
  end

  sequence :manifest_csv_bad_headers do |n|
    csv_string =<<-eos
bad_header1,bad_header2
fraggle,fraggle.pem
    eos
  end

  # We have a header row but nothing else
  sequence :empty_manifest_csv do |n|
    csv_string =<<-eos
username,ssh_key_file_name
    eos
    StringIO.new(csv_string)
  end
end