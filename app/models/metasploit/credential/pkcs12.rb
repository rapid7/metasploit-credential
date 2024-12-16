require 'openssl'
require 'base64'

# A private Pkcs12 file.
class Metasploit::Credential::Pkcs12 < Metasploit::Credential::Private

  #
  # Constants
  #

  # Valid format for {#data} composed of `'msf_pkcs12:<base64 cert>:<ca>:<ADCS template>'`.
  DATA_REGEXP = /\Amsf_pkcs12:(?<pkcs12>[^:]+):(?<ca>[^:]*):(?<adcs_template>.*)\z/
  private_constant :DATA_REGEXP

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

  validate :data_format

  validate :readable

  #
  # Class methods
  #

  # @param [Integer] pkcs12 The Base64-encoded  Pkcs12 certificate
  # @param [String,nil] ca The CA that issued the certificate
  # @param [String,nil] adcs_template The certificate template used to issue the certificate
  # @return [String]
  # @raise [ArgumentError] if an option is invalid
  def self.build_data(pkcs12:, ca: nil, adcs_template: nil)
    raise ArgumentError.new('pkcs12 must be set') if pkcs12.nil?
    raise ArgumentError.new('ca must be a non-empty string') if ca && (!ca.is_a?(String) || ca.empty?)
    raise ArgumentError.new('adcs_template must be a non-empty string') if adcs_template && (!adcs_template.is_a?(String) || adcs_template.empty?)

    "msf_pkcs12:#{pkcs12}:#{ca}:#{adcs_template}"
  end

  #
  # Instance Methods
  #
  #

  # The Base64-encoded Pkcs12 certificate
  #
  # @return [String]
  def pkcs12
    parsed_data[:pkcs12]
  end

  # The CA that issued the certificate
  #
  # @return [String]
  def ca
    parsed_data[:ca]
  end

  # The certificate template used to issue the certificate
  #
  # @return [String]
  def adcs_template
    parsed_data[:adcs_template]
  end

  # Converts the private pkcs12 data in {#data} to an `OpenSSL::PKCS12` instance.
  #
  # @return [OpenSSL::PKCS12]
  # @raise [ArgumentError] if {#data} cannot be loaded
  def openssl_pkcs12
    if data
      begin
        password = ''
        OpenSSL::PKCS12.new(Base64.strict_decode64(pkcs12), password)
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
    result << "CA:#{ca}" if ca
    result << "ADCS_template:#{adcs_template}" if adcs_template
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

  # @return [Hash] The parsed data with enctype, key, salt keys
  def parsed_data
    match = data.match(DATA_REGEXP)
    return {} unless match

    {
      pkcs12: match[:pkcs12],
      ca: match[:ca].empty? ? nil : match[:ca],
      adcs_template: match[:adcs_template].empty? ? nil : match[:adcs_template]
    }
  end

  # Validates that {#data} is in the expected data format
  def data_format
    unless DATA_REGEXP.match(data)
      errors.add(:data, :format)
    end
  end

  public

  Metasploit::Concern.run(self)
end
