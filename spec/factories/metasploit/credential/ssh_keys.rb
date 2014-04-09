FactoryGirl.define do
  factory :metasploit_credential_ssh_key,
          class: Metasploit::Credential::SSHKey do
    ignore do
      key_type { generate :metasploit_credential_ssh_key_key_type }
      key_size { 2048 }
    end

    data {
      key_class = OpenSSL::PKey.const_get(key_type)
      key_class.generate(key_size).to_s
    }

    factory :metasploit_credential_dsa_key do
      ignore do
        key_type :DSA
      end
    end

    factory :metasploit_credential_rsa_key do
      ignore do
        key_type :RSA
      end
    end
  end

  metasploit_credential_ssh_key_key_types = [:DSA, :RSA]
  sequence :metasploit_credential_ssh_key_key_type, metasploit_credential_ssh_key_key_types.cycle
end
