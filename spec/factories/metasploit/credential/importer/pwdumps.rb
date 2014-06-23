FactoryGirl.define do
  factory :metasploit_credential_importer_pwdump,
          class: Metasploit::Credential::Importer::Pwdump do
    filename "pwdump-import-#{Time.now.to_i}"
    origin {FactoryGirl.build :metasploit_credential_origin_import }
    input { FactoryGirl.generate(:wellformed_pwdump) }
  end

  # Represents a file that should do an error-free import
  # 2 Hosts
  # 1 Service per Host
  # 2 Publics
  # 5 Privates
  #   - 2 Password
  #   - 2 NonreplayableHash
  #   - 1 NTLMHash

  sequence :wellformed_pwdump do |n|
    pwdump_string = <<-EOS
# LM/NTLM Hashes (1 hashes, 1 services)
# 192.168.0.2:4567/snmp ()
metasploit_credential_public_username1:1:aad3b435b51404eeaad3b435b51404ee:79d2d315bcb541a94d4f094a74b46cb2:::


# Hashes (2 hashes, 2 services)
# 192.168.0.2:4567/snmp ()
metasploit_credential_public_username1:40bdee771d42eb80d47a7d34ed7fc0a318927197:::

# 192.168.0.3:4567/snmp ()
metasploit_credential_public_username2:1654f171e0123b54272d82fb7e94bdf214a9b2a4:::

#  Plaintext Passwords (2 hashes, 2 services)
# 192.168.0.2:4567/snmp ()
metasploit_credential_public_username1 metasploit_credential_password2

# 192.168.0.3:4567/snmp ()
metasploit_credential_public_username2 metasploit_credential_password3
  EOS
  StringIO.new(pwdump_string)
  end

end