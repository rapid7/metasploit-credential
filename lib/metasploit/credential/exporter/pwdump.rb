require 'erb'

class Metasploit::Credential::Exporter::Pwdump
  include Metasploit::Credential::Exporter::Base

  #
  # Constants
  #

  # The string inserted when either the public or private half of a credential is blank
  BLANK_CRED_STRING = '<BLANK>'

  # Where the MSF pwdump template lives
  TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), "pwdump_template.erb"))


  def rendered_output
    @version_string = "foobar"
    @workspace = "some workspace"
    template = ERB.new(File.read TEMPLATE_PATH)
    template.result get_binding
  end

  # Format a {Metasploit::Credential::Public} and a {Metasploit::Credential::NTLMHash} for output
  # @param [Metasploit::Credential::Login] login
  # @return[String]
  def format_ntlm_hash(login)
    creds_data = data_for_login(login)
    "#{creds_data[:username]}:#{login.id}:#{creds_data[:hash]}"
  end

  # Format a {Metasploit::Credential::Public} and a {Metasploit::Credential::NonReplayableHash} for output
  # @param [Metasploit::Credential::Login] login
  # @return[String]
  def format_nonreplayable_hash(login)
    creds_data = data_for_login(login)
    "#{creds_data[:username]}:#{creds_data[:hash]}"
  end


  private

  # Returns a hash containing the public and private or the canonical blank string
  # @param[Metasploit::Credential::Login] login
  # @return[Hash]
  def data_for_login(login)
    username = login.core.public.username.present? ? login.core.public.username : BLANK_CRED_STRING
    hash     = login.core.private.data.present? ? login.core.private.data : BLANK_CRED_STRING
    {
      username: username,
      hash: hash
    }
  end

  def get_binding
    binding.dup
  end
end
