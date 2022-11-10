require 'json'
require 'base64'

# A {Metasploit::Credential::Private} This class contains information relevant to a Kerberos Ticket
# https://www.rfc-editor.org/rfc/rfc4120.html#section-5.3
#
# The data format used for the ticket is a MIT krb5 ccache, although it is treated as an opaque base64 blob string
#
# {#data} is a serialized ruby hash with the keys defined in {Metasploit::Credential::KrbEncKey::ACCEPTABLE_DATA_ATTRIBUTES}
class Metasploit::Credential::KrbTicket < Metasploit::Credential::Private
  # TODO: What are the security ramifications of this if we leak user controlled input here
  serialize :data, MetasploitDataModels::Base64Serializer.new(default: {})

  #
  # Constants
  #
  ACCEPTABLE_DATA_ATTRIBUTES = [
    # TGT/TGS
    :type,
    # ccache mit blob
    :value,
    # see {#sname}
    :sname,
    # UTC time
    :starttime,
    # UTC time
    :authtime,
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

  # The starttime for this ticket
  #
  # @return [Time] The starttime
  def starttime
    data[:starttime]
  end


  # The authtime for this ticket
  #
  # @return [Time] The authtime
  def authtime
    data[:authtime]
  end

  # The endtime for this ticket
  #
  # @return [Time] The endtime
  def endtime
    data[:endtime]
  end

  # The Kerberos sname for this ticket, i.e. krbtgt/REALM.LOCAL or http/host.realm.local
  #
  # Service Principal Names (SPNs) are not case sensitive when used by Microsoft Windows-based computers.
  # However, an SPN can be used by any type of computer system.
  # https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc731241(v=ws.10)?redirectedfrom=MSDN
  #
  # @return [String] The string sname
  def sname
    data[:sname]
  end

  # A string suitable for displaying to the user
  #
  # @return [String]
  def to_s
    "#{type}:#{sname}:ccache:#{Base64.strict_encode64(value)}"
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
    errors.add(:data, :missing_sname) if sname.blank?
  end

  public

  Metasploit::Concern.run(self)
end
