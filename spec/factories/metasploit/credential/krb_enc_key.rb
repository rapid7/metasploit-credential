require 'openssl'

FactoryBot.define do
  klass = Metasploit::Credential::KrbEncKey

  factory :metasploit_credential_krb_enc_key,
          class: klass,
          parent: :metasploit_credential_password_hash do

    # By default - use the with_rc4 trait for performance reasons
    with_rc4

    trait :with_rc4 do
      data { generate(:metasploit_credential_krb_enc_key_rc4) }
    end

    trait :with_aes128 do
      data { generate(:metasploit_credential_krb_enc_key_aes128) }
    end

    trait :with_aes256 do
      data { generate(:metasploit_credential_krb_enc_key_aes256) }
    end
  end

  sequence :metasploit_credential_krb_enc_key_rc4 do |n|
    salt = nil
    password = "password#{n}"
    unicode_password = password.encode('utf-16le')
    key = OpenSSL::Digest.digest('MD4', unicode_password)
    enctype = 23

    klass.build_data(enctype: enctype, key: key, salt: salt)
  end

  sequence :metasploit_credential_krb_enc_key_aes128 do |n|
    salt = "DOMAIN.LOCALUserAccount#{n}"
    password = "password#{n}"
    key = aes_cts_hmac_sha1_96('128-CBC', password, salt)
    enctype = 17

    klass.build_data(enctype: enctype, key: key, salt: salt)
  end

  sequence :metasploit_credential_krb_enc_key_aes256 do |n|
    salt = "DOMAIN.LOCALUserAccount#{n}"
    password = "password#{n}"
    enctype = 18
    key = aes_cts_hmac_sha1_96('256-CBC', password, salt)

    klass.build_data(enctype: enctype, key: key, salt: salt)
  end

  # Encrypt using MIT Kerberos aesXXX-cts-hmac-sha1-96
  # http://web.mit.edu/kerberos/krb5-latest/doc/admin/enctypes.html?highlight=des#enctype-compatibility
  #
  # @param algorithm [String] The AES algorithm to use (e.g. `128-CBC` or `256-CBC`)
  # @param raw_secret [String] The data to encrypt
  # @param salt [String] The salt used by the encryption algorithm
  # @return [String, nil] The encrypted data
  def aes_cts_hmac_sha1_96(algorithm, raw_secret, salt)
    iterations = 4096
    cipher = OpenSSL::Cipher::AES.new(algorithm)
    key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(raw_secret, salt, iterations, cipher.key_len)
    plaintext = "kerberos\x7B\x9B\x5B\x2B\x93\x13\x2B\x93".b
    result = ''.b
    loop do
      cipher.reset
      cipher.encrypt
      cipher.iv = "\x00".b * 16
      cipher.key = key
      ciphertext = cipher.update(plaintext)
      result += ciphertext
      break unless result.size < cipher.key_len

      plaintext = ciphertext
    end
    result
  end

end
