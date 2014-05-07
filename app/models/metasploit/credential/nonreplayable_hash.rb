# A {Metasploit::Credential::PasswordHash password hash} that can be replayed to authenticate to other services.
# Contrast with {Metasploit::Credential::ReplayableHash}.  {#data} is any password hash, such as those recovered from
# `/etc/passwd` or `/etc/shadow`.
class Metasploit::Credential::NonreplayableHash < Metasploit::Credential::PasswordHash
  #
  # Attributes
  #

  # @!attribute data
  #   Password hash that cannot be replayable for authenticating to other services.
  #
  #   @return [String]

  Metasploit::Concern.run(self)
end
