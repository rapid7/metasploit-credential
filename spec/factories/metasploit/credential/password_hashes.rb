FactoryGirl.define do
  factory :metasploit_credential_password_hash,
          # no need to declare metasploit_credential_private as the :parent because :metasploit_credential_password_hash
          # uses its own data sequence to differentiate password hashes from other private data and #type is
          # automatically set by ActiveRecord because Metasploit::Credential::Password is an STI subclass.
          class: Metasploit::Credential::Password do
    data { generate :metasploit_credential_password_data }
  end

  sequence :metasploit_credential_password_hash_data do |n|
    Bcrypt::Password.create("metasploit_credential_password_hash_data#{n}").hash
  end
end
