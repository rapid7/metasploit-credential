require 'openssl'
require 'base64'

# A private Pkcs12 file.
class Metasploit::Credential::Pkcs12 < Metasploit::Credential::Private

  #
  # Attributes
  #

  # @!attribute data
  #   A private pkcs12 file, base64 encoded - i.e. starting with 'MIIMhgIBAzCCDFAGCSqGSIb3DQEHAaCC....'
  #
  #   @return [String]

  # @!attribute metadata
  #   Metadata for this Pkcs12:
  #     adcs_ca: The Certificate Authority that issued the certificate
  #     adcs_template: The certificate template used to issue the certificate
  #     pkcs12_password: The password to decrypt the Pkcs12
  #
  #   @return [JSONB]

  #
  #
  # Validations
  #
  #

  #
  # Attribute Validations
  #

  validates :data,
            presence: true

  #
  # Method Validations
  #

  validate :readable

  #
  # Class methods
  #

  #
  # Instance Methods
  #
  #

  # The CA that issued the certificate
  #
  # @return [String]
  def adcs_ca
    metadata['adcs_ca']
  end

  # The certificate template used to issue the certificate
  #
  # @return [String]
  def adcs_template
    metadata['adcs_template']
  end

  # The password to decrypt the Pkcs12
  #
  # @return [String]
  def pkcs12_password
    metadata['pkcs12_password']
  end

  # Converts the private pkcs12 data in {#data} to an `OpenSSL::PKCS12` instance.
  #
  # @return [OpenSSL::PKCS12]
  # @raise [ArgumentError] if {#data} cannot be loaded
  def openssl_pkcs12
    if data
      begin
        password = metadata.fetch('pkcs12_password', '')
        OpenSSL::PKCS12.new(Base64.strict_decode64(data), password)
      rescue OpenSSL::PKCS12::PKCS12Error => error
        raise ArgumentError.new(error)
      end
    end
  end

  # The {#data key data}'s fingerprint, suitable for displaying to the
  # user. The Pkcs12 password is voluntarily not included.
  #
  # @return [String]
  def to_s
    return '' unless data

    cert = openssl_pkcs12.certificate
    result = []
    result << "subject:#{cert.subject.to_s}"
    result << "issuer:#{cert.issuer.to_s}"
    result << "ADCS CA:#{metadata['adcs_ca']}" if metadata['adcs_ca']
    result << "ADCS template:#{metadata['adcs_template']}" if metadata['adcs_template']
    result.join(',')
  end


  private

  #
  # Validates that {#data} can be read by OpenSSL and a `OpenSSL::PKCS12` can be created from {#data}.  Any exception
  # raised will be reported as a validation error.
  #
  # @return [void]
  def readable
    if data
      begin
        openssl_pkcs12
      rescue => error
        errors.add(:data, "#{error.class} #{error}")
      end
    end
  end


  public

  Metasploit::Concern.run(self)
end
