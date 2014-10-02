# A public credential in the form of a Username.
class Metasploit::Credential::BlankUsername < Metasploit::Credential::Public

  after_initialize :blank_username

  def blank_username
    self.username ||= ''
  end

  Metasploit::Concern.run(self)
end