FactoryGirl.define do
  factory :metasploit_credential_core_importer,
          class: Metasploit::Credential::Importer::CSV::Core do

    data { generate(:well_formed_csv_io)}

  end

  sequence :well_formed_csv_io do |n|
    csv_string =<<-eos
public, private, realm_type, realm_name
han_solo-#{n}, falcon_chief, #{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN}, Rebels
princessl-#{n}, bagel_head,#{Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN}, Rebels
    eos
    StringIO.new(csv_string)
  end

end