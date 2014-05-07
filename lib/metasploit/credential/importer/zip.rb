# Creates {Metasploit::Credential::Core} objects and their associated {Metasploit::Credential::Public},
# and {Metasploit::Credential::SSHKey} objects given a well-formed zip file.
#
# A well-formed zip contains the following files in a flat structure:
#   * a Core file called 'manifest.csv' with headers as follows:
#     - public
#     - private_key_file_name
#   * one or more private key files in PEM format, referenced by the private_key_file_name field
#

class Metasploit::Credential::Importer::Zip < ActiveModel::Base



end