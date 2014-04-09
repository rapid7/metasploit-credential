FactoryGirl.define do
  factory :metasploit_credential_nonreplayable_hash,
          class: Metasploit::Credential::NonreplayableHash,
          parent: :metasploit_credential_password_hash
end
