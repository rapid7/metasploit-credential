# A public credential in the form of a Username.
class Metasploit::Credential::BlankUsername < Metasploit::Credential::Public

  after_initialize :blank_username

  #
  # Validations
  #

  validates :username,
            uniqueness: true

  def blank_username
    self.username ||= ''
  end

  Metasploit::Concern.run(self)
end