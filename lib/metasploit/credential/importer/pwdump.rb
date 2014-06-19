# Implements importation behavior for pwdump files exported by Metasploit as well as files from the John the Ripper
# hash cracking suite: http://www.openwall.com/john/
#
# Please note that in the case of data exported from Metasploit, the dataset will contain information on the {Mdm::Host}
# and {Mdm::Service} objects that are related to the credential.  This means that Metasploit exports will be limited to
# containing {Metasploit::Credential::Login} objects, which is the legacy behavior of this export prior to the creation
# of this library.
class Metasploit::Credential::Importer::Pwdump
  include Metasploit::Credential::Importer::Base

  #
  # Constants
  #

  # Matches a line starting with a '#'
  COMMENT_LINE_START_REGEX     = /^[\s]*#/

  # The string that John the Ripper uses to designate a lack of password in a credentials entry
  JTR_NO_PASSWORD_STRING = "NO PASSWORD"

  # Matches lines that contain usernames and plaintext passwords
  PLAINTEXT_REGEX              = /^[\s]*([\x21-\x7f]+)[\s]+([\x21-\x7f]+)?/n

  # Matches a line that we use to get information for creating {Mdm::Host} and {Mdm::Service} objects
  # TODO: change to use named groups from 1.9+
  SERVICE_COMMENT_REGEX        = /^#[\s]*([0-9.]+):([0-9]+)(\x2f(tcp|udp))?[\s]*(\x28([^\x29]*)\x29)?/n

  # Matches the way that John the Ripper exports SMB hashes with no password piece
  SMB_WITH_JTR_BLANK_PASSWORD_REGEX = /^[\s]*([^\s:]+):([0-9]+):NO PASSWORD\*+:NO PASSWORD\*+[^\s]*$/

  # Matches LM/NTLM hash format
  SMB_WITH_HASH_REGEX          = /^[\s]*([^\s:]+):[0-9]+:([A-Fa-f0-9]+:[A-Fa-f0-9]+):[^\s]*$/

  # Matches a line with free-form text - less restrictive than {SMB_WITH_HASH_REGEX}
  SMB_WITH_PLAINTEXT_REGEX     = /^[\s]*([^\s:]+):(.+):[A-Fa-f0-9]*:[A-Fa-f0-9]*:::$/

  #
  # Instance Methods
  #

  # Perform the import of the credential data, creating {Mdm::Host} and {Mdm::Service} objects as needed
  # @return [void]
  def import!
    service_info = nil

    input.each_line do |line|
      case line
        when COMMENT_LINE_START_REGEX
          service_info = service_info_from_comment_string(line)
        when SMB_WITH_HASH_REGEX
          info = parsed_regex_results($1, $2)
          user, pass = info[:user], info[:pass]
          creds_class = Metasploit::Credential::NTLMHash
        when SMB_WITH_JTR_BLANK_PASSWORD_REGEX
          info = parsed_regex_results($1, $2)
          user, pass = info[:user], info[:pass]
          creds_class = Metasploit::Credential::NTLMHash
        when SMB_WITH_PLAINTEXT_REGEX
          info = parsed_regex_results($1, $2)
          user, pass = info[:user], info[:pass]
          creds_class = Metasploit::Credential::NTLMHash
        when PLAINTEXT_REGEX
          info = parsed_regex_results($1, $2, true)
          user, pass = info[:user], info[:pass]
          creds_class = Metasploit::Credential::Password
        else
          next
      end

      # create the cred Core via the Creation methods to
      # ensure that the Host and Service objects get created

    end
  end


  # Break a line into user, hash, and type
  # @param [String] username
  # @param [String] password
  # @param [Boolean] dehex convert hex to char if true
  # @return [Hash]
  def parsed_regex_results(username, password, dehex=false)
    results = {}
    results[:user]  = blank_or_string(username, dehex)
    results[:pass]  = blank_or_string(password, dehex)

    results
  end



  # Checks a string for matching {Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING} and returns blank string
  # if it matches that constant.
  # @param [String] check_string the string to check
  # @param [Boolean] dehex convert hex to char if true
  # @return [String]
  def blank_or_string(check_string, dehex=false)
    if check_string.nil? || check_string ==  Metasploit::Credential::Exporter::Pwdump::BLANK_CRED_STRING || JTR_NO_PASSWORD_STRING
      ""
    else
      if dehex
        Metasploit::Credential::Text.dehex check_string
      else
        check_string
      end
    end
  end

  # Take an msfpwdump comment string and parse it into information necessary for
  # creating {Mdm::Host} and {Mdm::Service} objects.
  # @param [String] comment_string a string starting with a '#' that conforms to {SERVICE_COMMENT_REGEX}
  # @return [Hash]
  def service_info_from_comment_string(comment_string)
    service_info = {}
    if comment_string[SERVICE_COMMENT_REGEX]
      service_info[:host_address]  = $1
      service_info[:port]          = $2
      service_info[:protocol]      = $4
      service_info[:name]          = $6
      service_info
    else
      nil
    end
  end


end


