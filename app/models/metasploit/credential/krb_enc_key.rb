require 'json'

# A {Metasploit::Credential::PasswordHash password hash} that cannot be replayed to authenticate to other services.
# {#data} is a string in the format `'msf_krbenckey:<enctype digits>:<key hexadecimal>:<salt hexadecimal>'`.
#
# This class contains information relevant to a Kerberos EncryptionKey https://www.rfc-editor.org/rfc/rfc4120.html#section-5.2.9
# which is used to encrypt/decrypt arbitrary Kerberos protocol message data - such as the AS-REP krbtgt ticket and enc-part.
class Metasploit::Credential::KrbEncKey < Metasploit::Credential::PasswordHash

  #
  # Constants
  #

  # Valid format for KrbEncKey enctype portion of {#data}: numeric characters
  # @see ENCTYPE_NAMES
  TYPE_REGEXP = /(?<enctype>\d+)/
  private_constant :TYPE_REGEXP

  # Valid format for KrbEncKey key portion of {#data}: lowercase hexadecimal characters
  KEY_REGEXP = /(?<key>[0-9a-f]+)/
  private_constant :KEY_REGEXP

  # Valid format for KrbEncKey enctype portion of {#data}: lowercase hexadecimal characters
  SALT_REGEXP = /(?<salt>[0-9a-f]*)/
  private_constant :SALT_REGEXP

  # Valid format for {#data} composed of `'msf_krbenckey:<enctype digits>:<key hexadecimal>:<salt hexadecimal>'`.
  DATA_REGEXP = /\Amsf_krbenckey:#{TYPE_REGEXP}:#{KEY_REGEXP}:#{SALT_REGEXP}\z/
  private_constant :DATA_REGEXP

  # https://www.iana.org/assignments/kerberos-parameters/kerberos-parameters.xhtml
  ENCTYPE_NAMES = (Hash.new { |_hash, enctype| "unassigned-#{enctype}" }).merge({
    0 => 'reserved-0',
    1 => 'des-cbc-crc',
    2 => 'des-cbc-md4',
    3 => 'des-cbc-md5',
    4 => 'reserved-4',
    5 => 'des3-cbc-md5',
    6 => 'reserved-6',
    7 => 'des3-cbc-sha1',
    8 => 'unassigned-8',
    9 => 'dsaWithSHA1-CmsOID',
    10 => 'md5WithRSAEncryption-CmsOID',
    11 => 'sha1WithRSAEncryption-CmsOID',
    12 => 'rc2CBC-EnvOID',
    13 => 'rsaEncryption-EnvOID',
    14 => 'rsaES-OAEP-ENV-OID',
    15 => 'des-ede3-cbc-Env-OID',
    16 => 'des3-cbc-sha1-kd',
    17 => 'aes128-cts-hmac-sha1-96',
    18 => 'aes256-cts-hmac-sha1-96',
    19 => 'aes128-cts-hmac-sha256-128',
    20 => 'aes256-cts-hmac-sha384-192',
    21 => 'unassigned-21',
    22 => 'unassigned-22',
    23 => 'rc4-hmac',
    24 => 'rc4-hmac-exp',
    25 => 'camellia128-cts-cmac',
    26 => 'camellia256-cts-cmac',
    65 => 'subkey-keymaterial'
  })
  private_constant :ENCTYPE_NAMES

  #
  # Attributes
  #

  # @!attribute data
  #
  #   @return [Hash{Symbol => String}]

  #
  # Callbacks
  #

  before_validation :normalize_data

  #
  # Validations
  #

  validate :data_format

  #
  # Class methods
  #

  # @param [Integer] enctype The enctype
  # @param [String] key The key bytes
  # @param [String,nil] salt The salt
  # @return [String]
  # @raise [ArgumentError] if an option is invalid
  def self.build_data(enctype:, key:, salt: nil)
    raise ArgumentError('enctype must be numeric') unless enctype.is_a?(Numeric)
    raise ArgumentError('key must be set') if key.nil?

    "msf_krbenckey:#{enctype}:#{as_hex(key)}:#{as_hex(salt)}"
  end

  #
  # Instance Methods
  #

  # The enctype as defined by https://www.iana.org/assignments/kerberos-parameters/kerberos-parameters.xhtml
  #
  # @return [Integer]
  def enctype
    parsed_data[:enctype]
  end

  # The key
  #
  # @return [String]
  def key
    parsed_data[:key]
  end

  # The salt used as part of creating the key. This is normally derived from the Kerberos principal name/Realm.
  # For windows the following convention is used to create the salt:
  # https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-kile/7a7b081d-c0c6-46f4-acbf-a439664270b8
  #
  # This value can be nil if the salt is not known
  # @return [String,nil] The key salt if available
  def salt
    parsed_data[:salt]
  end

  # A string suitable for displaying to the user
  #
  # @return [String]
  def to_s
    "#{ENCTYPE_NAMES[enctype]}:#{self.class.as_hex(key)}#{salt ? ":#{self.class.as_hex(salt)}" : ''}"
  end

  private

  # Converts a buffer containing bytes to a String containing the hex representation of the bytes
  #
  # @param hash [String,nil] a buffer of bytes
  # @return [String] a string where every 2 hexadecimal characters represents a byte in the original hash buffer
  def self.as_hex(value)
    value.to_s.unpack1('H*')
  end

  # Converts a buffer containing bytes to a String containing the hex representation of the bytes
  #
  # @param hash [String,nil] a buffer of bytes
  # @return [String] a string where every 2 hexadecimal characters represents a byte in the original hash buffer
  def self.as_bytes(value)
    [value.to_s].pack('H*')
  end

  # @return [Hash] The parsed data with enctype, key, salt keys
  def parsed_data
    match = data.match(DATA_REGEXP)
    return {} unless match

    {
      enctype: match[:enctype].to_i,
      key: self.class.as_bytes(match[:key]),
      salt: match[:salt].empty? ? nil : self.class.as_bytes(match[:salt])
    }
  end

  # Normalizes {#data} by making it all lowercase so that the unique validation and index on
  # ({Metasploit::Credential::Private#type}, {#data}) catches collision in a case-insensitive manner without the need
  # to use case-insensitive comparisons.
  def normalize_data
    if data
      self.data = data.downcase
    end
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
