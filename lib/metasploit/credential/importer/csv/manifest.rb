# Implements importing behavior for the manifest.csv file that is used in a {Metasploit::Credential::Importer::Zip}
class Metasploit::Credential::Importer::CSV::Manifest < Metasploit::Credential::Importer::CSV::Base
  VALID_CSV_HEADERS = [:username, :ssh_key_file_name]

  #
  # Instance Methods
  #

  def import!
    csv_object.each do |row|
      next if row.header_row?

      ssh_key_data = key_data_from_file(row['ssh_key_file_name'])
      public_object_for_row  = Metasploit::Credential::Public.where(username: row['username']).first_or_create
      private_object_for_row = Metasploit::Credential::SSHKey.where(data: ssh_key_data).first_or_create

      create_core(public: public_object_for_row, private: private_object_for_row)
    end
  end


end