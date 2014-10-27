# Changelog

## v0.13.0

* Enhancements
  * [#76](https://github.com/rapid7/metasploit-credential/pull/76) - [@dmaloney](https://github.com/dmaloney-r7)
    * Blank passwords (`Metasploit::Credential::BlankPassword`) and usernames (`Metasploit::Credential::BlankUsername`),
      including importer detecting `<BLANK>`.
    * Metasploit::Credential::Core` with only a realm is now valid.

* Incompatible Changes
  * [#76](https://github.com/rapid7/metasploit-credential/pull/76) - [@dmaloney](https://github.com/dmaloney-r7)
    * `Metasploit::Credential::Public` uses Single-Table Inheritance (STI), so SQL access need to be aware of the `type` column.
    * The `:metasploit_credential_public` factory will now randomly generate a `Metasploit::Credential::BlankUsername`
      or `Metasploit::Credential::Username`.  If you use `:metasploit_credential_public`, you need to ensure that you
      can handle blank usernames, otherwise use `:metasploit_credential_username` to get the old behavior.