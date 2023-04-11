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
    end

    data {
      password = ''
      pkcs12_name = ''

      private_key = OpenSSL::PKey::RSA.new(key_size)
      public_key = private_key.public_key

      cert = OpenSSL::X509::Certificate.new
      cert.subject = OpenSSL::X509::Name.parse(subject)
      cert.issuer = OpenSSL::X509::Name.parse(issuer)
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.public_key = public_key
      cert.serial = 0x0
      cert.version = 2
      cert.sign(private_key, OpenSSL::Digest.new(signing_algorithm))

      pkcs12 = OpenSSL::PKCS12.create(password, pkcs12_name, private_key, cert)
      pkcs12_base64 = Base64.strict_encode64(pkcs12.to_der)
      pkcs12_base64
    }
  end
end
