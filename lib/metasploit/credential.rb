# Only include the Rails engine when using Rails.  This is for compatibility with metasploit-framework.
if defined? Rails
  require 'metasploit/credential/engine'
end

# Shared namespace for metasploit gems; used in [metasploit-credential](https://github.com/rapid7/metasploit-credential),
# [metasploit-framework](https://github.com/rapid7/metasploit-framework), and
# [metasploit-model](https://github.com/rapid7/metasploit-model)
module Metasploit
  # The namespace for this gem.
  module Credential

  end
end
