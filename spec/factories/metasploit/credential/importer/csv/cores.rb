FactoryGirl.define do
  factory :metasploit_credential_core_importer_well_formed_compliant,
          class: Metasploit::Credential::Importer::CSV::Core do

    origin {FactoryGirl.build :metasploit_credential_origin_import }
    data { generate(:well_formed_csv_io_compliant_header)}
  end

  factory :metasploit_credential_core_importer_well_formed_non_compliant,
          class: Metasploit::Credential::Importer::CSV::Core do

    origin {FactoryGirl.build :metasploit_credential_origin_import }
    data { generate(:well_formed_csv_io_non_compliant_header)}
  end

  # Well-formed CSV
  # Has a compliant header as defined by Metasploit::Credential::Importer::CSV::Core
  sequence :well_formed_csv_io_compliant_header do |n|
    csv_string =<<-eos
username,private_type,private_data,realm_key,realm_value
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
lord_vader-#{n},#{Metasploit::Credential::Password.name},evilisfun,#{Metasploit::Credential::Realm::Key::ORACLE_SYSTEM_IDENTIFIER},dstar_admins
    eos
    StringIO.new(csv_string)
  end

  # Well-formed CSV
  # Has a *non-compliant* header as defined by Metasploit::Credential::Importer::CSV::Core
  sequence :well_formed_csv_io_non_compliant_header do |n|
    csv_string =<<-eos
notgood,noncompliant,badheader,morebadheader
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief, #{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
    eos
    StringIO.new(csv_string)
  end

end