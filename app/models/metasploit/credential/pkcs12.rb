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
  # Instance Methods
  #

  # Converts the private pkcs12 data in {#data} to an `OpenSSL::PKCS12` instance.
  #
  # @return [OpenSSL::PKCS12]
  # @raise [ArgumentError] if {#data} cannot be loaded
  def openssl_pkcs12
    if data
      begin
        password = ''
        OpenSSL::PKCS12.new(Base64.strict_decode64(data), password)
      rescue OpenSSL::PKCS12::PKCS12Error => error
        raise ArgumentError.new(error)
      end
    end
  end

  # The {#data key data}'s fingerprint, suitable for displaying to the
  # user.
  #
  # @return [String]
  def to_s
    return '' unless data

    cert = openssl_pkcs12.certificate
    result = []
    result << "subject:#{cert.subject.to_s}"
    result << "issuer:#{cert.issuer.to_s}"
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

  Metasploit::Concern.run(self)
end
