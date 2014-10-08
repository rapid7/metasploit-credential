# A blank password
class Metasploit::Credential::BlankPassword < Metasploit::Credential::Password

  before_save :blank_data

  #
  # Validations
  #

  validates :data,
            uniqueness: true

  # This method always makes sure the BlankPassword is set to an empty string.
  #
  # @return [void]
  def blank_data
    self.data = ''
  end

  Metasploit::Concern.run(self)
end