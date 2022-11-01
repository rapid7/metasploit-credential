require 'json'
require 'base64'

# This class contains information relevant to a Kerberos Ticket https://www.rfc-editor.org/rfc/rfc4120.html#section-5.3
# The data format used for the ticket is is MIT krb5 ccache, although it is treated as an opaque base64 blob string
class Metasploit::Credential::KrbTicket < Metasploit::Credential::Private
  # TODO: What are the security rammifications of this if we leak user controlled input here
  serialize :data, MetasploitDataModels::Base64Serializer.new(default: {})

  #
  # Constants
  #
  ACCEPTABLE_DATA_ATTRIBUTES = [
    # TGT/TGS
    :type,
    # ccache mit blob
    :value,
    # UTC time
    :endtime
  ]
  private_constant :ACCEPTABLE_DATA_ATTRIBUTES

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

  # The type, either tgt or tgs
  #
  # @return [Symbol]
  def type
    data[:type]
  end

  # The ticket value
  #
  # @return [String]
  def value
    data[:value]
  end

  # The endtime for this ticket
  #
  # @return [DateTime] The endtime
  def endtime
    data[:endtime]
  end

  # A string suitable for displaying to the user
  #
  # @return [String]
  def to_s
    "#{type}:ccache:#{Base64.strict_encode64(value)}"
  end

  #
  # Validations
  #

  validates :data,
            presence: true

  private

  # Validates that {#data} is in the expected data format
  def data_format
    invalid_data_attribute = data.keys - ACCEPTABLE_DATA_ATTRIBUTES
    invalid_data_attribute.each do |invalid_data_attribute|
      errors.add(:data, :invalid_data_attribute, attribute: invalid_data_attribute)
    end

    errors.add(:data, :missing_type) if type.blank?
    errors.add(:data, :missing_value) if value.blank?
    errors.add(:data, :missing_endtime) if endtime.blank?
  end

  public

  Metasploit::Concern.run(self)
end
