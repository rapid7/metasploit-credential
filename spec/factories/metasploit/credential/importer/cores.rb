FactoryGirl.define do
  factory :metasploit_credential_core_importer,
          class: Metasploit::Credential::Importer::Core do

    origin {FactoryGirl.build :metasploit_credential_origin_import }
    input { generate(:well_formed_csv_compliant_header)}
  end

  # Well-formed CSV
  # Has a compliant header as defined by Metasploit::Credential::Importer::Core
  # Contains 2 realms
  sequence :well_formed_csv_compliant_header do |n|
    csv_string =<<-eos
username,private_type,private_data,realm_key,realm_value,host_address,service_port,service_name,service_protocol
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief,#{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,#{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
lord_vader-#{n},#{Metasploit::Credential::Password.name},evilisfun,#{Metasploit::Model::Realm::Key::ORACLE_SYSTEM_IDENTIFIER},dstar_admins
    eos
    StringIO.new(csv_string)
  end

  # Well-formed CSV
  # Has a compliant header as defined by Metasploit::Credential::Importer::Core
  # Contains 2 logins
  sequence :well_formed_csv_compliant_header_with_service_info do |n|
    csv_string =<<-eos
username,private_type,private_data,realm_key,realm_value,host_address,service_port,service_name,service_protocol
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief,#{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels,10.0.1.1,1234,smb,tcp
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,#{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels,10.0.1.2,1234,smb,tcp
lord_vader-#{n},#{Metasploit::Credential::Password.name},evilisfun,#{Metasploit::Model::Realm::Key::ORACLE_SYSTEM_IDENTIFIER},dstar_admins
    eos
    StringIO.new(csv_string)
  end

  # Well-formed CSV
  # Has a compliant header as defined by Metasploit::Credential::Importer::Core
  # Contains no realm data
  sequence :well_formed_csv_compliant_header_no_realm do |n|
    csv_string =<<-eos
username,private_type,private_data,realm_key,realm_value,host_address,service_port,service_name,service_protocol
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief,,
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,,
lord_vader-#{n},#{Metasploit::Credential::Password.name},evilisfun,,
    eos
    StringIO.new(csv_string)
  end


  # Well-formed CSV
  # Conforms to "short" form, in which only username and private_data are specified in the file
  sequence :short_well_formed_csv do |n|
    csv_string =<<-eos
username,private_data
han_solo-#{n},falC0nBaws
princessl-#{n},bagelHead
    eos
    StringIO.new(csv_string)
  end

  # Well-formed CSV, non-compliant headers
  # Conforms to "short" form, in which only username and private_data are specified in the file
  sequence :short_well_formed_csv_non_compliant_header do |n|
    csv_string =<<-eos
bad,wrong
han_solo-#{n},falC0nBaws
princessl-#{n},bagelHead
    eos
    StringIO.new(csv_string)
  end

  sequence :well_formed_csv_non_compliant_header do |n|
    csv_string =<<-eos
notgood,noncompliant,badheader,morebadheader
han_solo-#{n},#{Metasploit::Credential::Password.name},falcon_chief, #{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
princessl-#{n},#{Metasploit::Credential::Password.name},bagel_head,#{Metasploit::Model::Realm::Key::ACTIVE_DIRECTORY_DOMAIN},Rebels
    eos
    StringIO.new(csv_string)
  end

  # Odd number of quotes will throw CSV::MalformedCSVError
  sequence :malformed_csv do |n|
    csv_string =<<-eos
foo,{"""}
    eos
    StringIO.new(csv_string)
  end

  # We have a header row but nothing else
  sequence :empty_core_csv do |n|
    csv_string =<<-eos
username,private_type,private_data,realm_key,realm_value,host_address,service_port,service_name,service_protocol
    eos
    StringIO.new(csv_string)
  end
end
