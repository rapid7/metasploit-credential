FactoryGirl.define do
  klass = Metasploit::Credential::Realm

  factory :metasploit_credential_realm,
          class: klass do
    key { generate :metasploit_credential_realm_key }
    value { generate :metasploit_credential_realm_value }

    factory :metasploit_credential_active_directory_domain do
      key { klass::Key::ACTIVE_DIRECTORY_DOMAIN }
      value { generate :metasploit_credential_active_directory_domain_value }
    end

    factory :metasploit_credential_db2_database do
      key { klass::Key::DB2_DATABASE }
      value { generate :metasploit_credential_db2_database_value }
    end

    factory :metasploit_credential_oracle_system_identifier do
      key { klass::Key::ORACLE_SYSTEM_IDENTIFIER }
      value { generate :metasploit_credential_oracle_system_identifier_value }
    end

    factory :metasploit_credential_postgresql_database do
      key { klass::Key::POSTGRESQL_DATABASE }
      value { generate :metasploit_credential_postgresql_database_value }
    end
  end

  sequence :metasploit_credential_active_directory_domain_value do |n|
    "DOMAIN#{n}"
  end

  sequence :metasploit_credential_db2_database_value do |n|
    "db2_database#{n}"
  end

  sequence :metasploit_credential_oracle_system_identifier_value do |n|
    "oracle_system_identifier#{n}"
  end

  sequence :metasploit_credential_postgresql_database_value do |n|
    "postgressql_database#{n}"
  end

  sequence :metasploit_credential_realm_key, klass::Key::ALL.cycle

  sequence :metasploit_credential_realm_value do |n|
    "metasploit_credential_realm_value#{n}"
  end
end
