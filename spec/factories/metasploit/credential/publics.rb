FactoryGirl.define do
  factory :metasploit_credential_public,
          class: Metasploit::Credential::Username do
    username { generate :metasploit_credential_public_username }
  end

  sequence :metasploit_credential_public_username do |n|
    "metasploit_credential_public_username#{n}"
  end
end