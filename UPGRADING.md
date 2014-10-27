# Upgrading

## V0.13.0

* If you use `:metasploit_credential_public`, you need to ensure that you can handle blank usernames, otherwise use
  `:metasploit_credential_username` to get the old behavior.