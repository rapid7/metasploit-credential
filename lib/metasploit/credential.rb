

# Only include the Rails engine when using Rails.  This is for compatibility with metasploit-framework.
if defined? Rails
  require 'metasploit/credential/engine'
end

module Metasploit
  module Credential

  end
end
