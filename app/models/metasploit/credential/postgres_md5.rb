# A {Metasploit::Credential::PasswordHash password hash} that can be {Metasploit::Credential::ReplayableHash replayed}
# to authenticate to PostgreSQL servers. It is composed of a hexadecimal string of 32 charachters prepended by the string
# 'md5'
class Metasploit::Credential::PostgresMD5 < Metasploit::Credential::ReplayableHash
  #
  # CONSTANTS
  #

  # Valid format for {Metasploit::Credential::Private#data}
  DATA_REGEXP = /md5([a-f0-9]{32})/

  #
  # Callbacks
  #

  serialize :data, Metasploit::Credential::CaseInsensitiveSerializer
  validates_uniqueness_of :data, :case_sensitive => false

  #
  # Validations
  #

  validate :data_format

  private

  def data_format
    unless DATA_REGEXP.match(data)
      errors.add(:data, 'is not in Postgres MD5 Hash format')
    end
  end

  public

  Metasploit::Concern.run(self)

end
