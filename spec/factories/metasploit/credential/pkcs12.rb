FactoryBot.define do
  factory :metasploit_credential_pkcs12,
          class: Metasploit::Credential::Pkcs12 do
    transient do
      # key size tuned for speed.  DO NOT use for production, it is below current recommended key size of 2048
      key_size { 1024 }
      # signing algorithm for the pkcs12 cert
      signing_algorithm { 'SHA256' }
      # the cert subject
      subject { '/C=BE/O=Test/OU=Test/CN=Test' }
      # the cert issuer
      issuer { '/C=BE/O=Test/OU=Test/CN=Test' }
      # the pkcs12 password
      pkcs12_password { '' }
      # the cert not_before date
      not_before { Time.now }
      # the cert not_after date
      not_after { Time.now + 365 * 24 * 60 * 60 }
    end

    data {
      pkcs12_name = ''

      private_key = OpenSSL::PKey::RSA.new(key_size)
      public_key = private_key.public_key

      cert = OpenSSL::X509::Certificate.new
      cert.subject = OpenSSL::X509::Name.parse(subject)
      cert.issuer = OpenSSL::X509::Name.parse(issuer)
      cert.not_before = not_before
      cert.not_after = not_after
      cert.public_key = public_key
      cert.serial = 0x0
      cert.version = 2
      cert.sign(private_key, OpenSSL::Digest.new(signing_algorithm))

      pkcs12 = OpenSSL::PKCS12.create(pkcs12_password, pkcs12_name, private_key, cert)
      Base64.strict_encode64(pkcs12.to_der)
    }
  end

  factory :metasploit_credential_pkcs12_with_ca, parent: :metasploit_credential_pkcs12 do
    transient do
      # The CA that issued the certificate
      adcs_ca { 'test-ca' }
    end

    metadata { { adcs_ca: adcs_ca } }
  end

  factory :metasploit_credential_pkcs12_with_adcs_template, parent: :metasploit_credential_pkcs12 do
    transient do
      # The certificate template used to issue the certificate
      adcs_template { 'User' }
    end

    metadata { { adcs_template: adcs_template} }
  end

  factory :metasploit_credential_pkcs12_with_pkcs12_password, parent: :metasploit_credential_pkcs12 do
    transient do
      # The password to decrypt the pkcs12
      pkcs12_password { 'Password!' }
    end

    metadata { { pkcs12_password: pkcs12_password } }
  end

  factory :metasploit_credential_pkcs12_with_status, parent: :metasploit_credential_pkcs12 do
    transient do
      # The CA that issued the certificate
      status { 'active' }
    end

    metadata { { status: status } }
  end

  factory :metasploit_credential_pkcs12_with_ca_and_adcs_template, parent: :metasploit_credential_pkcs12 do
    transient do
      adcs_ca { 'test-ca' }
      adcs_template { 'User' }
    end

    metadata { { adcs_ca: adcs_ca, adcs_template: adcs_template } }
  end

  factory :metasploit_credential_pkcs12_with_ca_and_adcs_template_and_pkcs12_password, parent: :metasploit_credential_pkcs12 do
    transient do
      adcs_ca { 'test-ca' }
      adcs_template { 'User' }
      pkcs12_password { 'Password!' }
    end

    metadata { { adcs_ca: adcs_ca, adcs_template: adcs_template, pkcs12_password: pkcs12_password } }
  end

end
