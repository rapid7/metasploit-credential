FactoryGirl.define do
  factory :metasploit_credential_core_importer_well_formed_compliant,
          class: Metasploit::Credential::Importer::CSV::Core do

    data { generate(:well_formed_csv_io_compliant_header)}
  end

  factory :metasploit_credential_core_importer_well_formed_non_compliant,
          class: Metasploit::Credential::Importer::CSV::Core do

    data { generate(:well_formed_csv_io_non_compliant_header)}
  end

  # Well-formed CSV
  # Has a compliant header as defined by Metasploit::Credential::Importer::CSV::Core
  sequence :well_formed_csv_io_compliant_header do |n|
    csv_string =<<-eos
public,private,realm_type,realm_name
han_solo-#{n},falcon_chief,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},bagel_head,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
    eos
    StringIO.new(csv_string)
  end

  # Well-formed CSV
  # Has a *non-compliant* header as defined by Metasploit::Credential::Importer::CSV::Core
  sequence :well_formed_csv_io_non_compliant_header do |n|
    csv_string =<<-eos
notgood,noncompliant,badheader,morebadheader
han_solo-#{n},falcon_chief, #{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},bagel_head,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
    eos
    StringIO.new(csv_string)
  end

end