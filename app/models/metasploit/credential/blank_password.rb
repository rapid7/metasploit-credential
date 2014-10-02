# A blank password
class Metasploit::Credential::BlankPassword < Metasploit::Credential::Password

  after_initialize :blank_data

  #
  # Validations
  #

  validates :data,
            uniqueness: true

  def blank_data
    self.data ||= ''
  end

  Metasploit::Concern.run(self)
end