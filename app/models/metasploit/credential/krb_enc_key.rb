require 'json'

# A {Metasploit::Credential::PasswordHash password hash} that cannot be replayed to authenticate to other services.
# {#data} is a serialized ruby hash with the keys defined in {Metasploit::Credential::KrbEncKey::ACCEPTABLE_DATA_ATTRIBUTES}
#
# This class contains information relevant to a Kerberos EncryptionKey https://www.rfc-editor.org/rfc/rfc4120.html#section-5.2.9
# which is used to encrypt/decrypt arbitrary Kerberos protocol message data - such as the AS-REP krbtgt ticket and enc-part.
class Metasploit::Credential::KrbEncKey < Metasploit::Credential::PasswordHash
  # TODO: What are the security rammifications of this if we leak user controlled input here
  serialize :data, MetasploitDataModels::Base64Serializer.new(default: {})

  #
  # Constants
  #
  ACCEPTABLE_DATA_ATTRIBUTES = %i[
    enctype
    key
    salt
  ]
  private_constant :ACCEPTABLE_DATA_ATTRIBUTES

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
  # Validations
  #

  validates :data,
            non_nil: true

  validate :data_format

  #
  # Instance Methods
  #

  # The enctype as defined by https://www.iana.org/assignments/kerberos-parameters/kerberos-parameters.xhtml
  #
  # @return [Integer]
  def enctype
    data[:enctype]
  end

  # The the key
  #
  # @return [String]
  def key
    data[:key]
  end

  # The salt used as part of creating the key. This is normally derived from the Kerberos principal name/Realm.
  # For windows the following convention is used to create the salt:
  # https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-kile/7a7b081d-c0c6-46f4-acbf-a439664270b8
  #
  # This value can be nil if the salt is not known
  # @return [String,nil] The key salt if available
  def salt
    data[:salt]
  end

  # A string suitable for displaying to the user
  #
  # @return [String]
  def to_s
    "#{ENCTYPE_NAMES[enctype]}:#{key.unpack1('H*')}"
  end

  private

  # Validates that {#data} is in the expected data format
  def data_format
    invalid_data_attribute = data.keys - ACCEPTABLE_DATA_ATTRIBUTES
    invalid_data_attribute.each do |invalid_data_attribute|
      errors.add(:data, :invalid_data_attribute, attribute: invalid_data_attribute)
    end

    errors.add(:data, :missing_key) if key.blank?
    errors.add(:data, :missing_enctype) if enctype.blank?
  end

  public

  Metasploit::Concern.run(self)
end
