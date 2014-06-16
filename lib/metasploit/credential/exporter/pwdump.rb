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

  #
  # Instance Methods
  #

  def data
    unless instance_variable_defined? :@data
      @data = {}
      @data[:ntlm]           = logins.select{ |l| l.core.private.is_a? Metasploit::Credential::NTLMHash }
      @data[:non_replayable] = logins.select{ |l| l.core.private.is_a? Metasploit::Credential::NonreplayableHash }
    end
    @data
  end

  # The collection of {Metasploit::Credential::Login} objects that will get parsed for output in the export
  # @return [ActiveRecord::Relation]
  def logins
    @logins ||= Metasploit::Credential::Login.in_workspace_including_hosts_and_services(workspace)
  end

  # Format a {Metasploit::Credential::Public} and a {Metasploit::Credential::NonReplayableHash} for output
  # @param [Metasploit::Credential::Login] login
  # @return[String]
  def format_nonreplayable_hash(login)
    creds_data = data_for_login(login)
    username = Metasploit::Credential::Text.ascii_safe_hex(creds_data[:username])
    hash     = Metasploit::Credential::Text.ascii_safe_hex(creds_data[:hash])
    "#{username}:#{hash}:::"
  end

  # Format a {Metasploit::Credential::Public} and a {Metasploit::Credential::NTLMHash} for output
  # @param [Metasploit::Credential::Login] login
  # @return[String]
  def format_ntlm_hash(login)
    creds_data = data_for_login(login)
    "#{creds_data[:username]}:#{login.id}:#{creds_data[:hash]}"
  end
  
  def rendered_output
    @version_string = "foobar"
    @workspace = "some workspace"
    template = ERB.new(File.read TEMPLATE_PATH)
    template.result get_binding
  end

  # Returns the count of services in the group creds contained in +hash_array+
  # @param [Array<Metasploit::Credential::Login>] hash_array
  # @return [Fixnum]
  def service_count_for_hashes(hash_array)
    hash_array.collect(&:service).collect(&:id).uniq.size
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
