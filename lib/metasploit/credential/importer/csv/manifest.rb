# Implements importing behavior for the manifest.csv file that is used in a {Metasploit::Credential::Importer::Zip}
class Metasploit::Credential::Importer::CSV::Manifest < Metasploit::Credential::Importer::CSV::Base
  VALID_CSV_HEADERS = [:username, :ssh_key_file_name]

  #
  # Instance Methods
  #

  def import!
    csv_object.each do |row|
      next if row.header_row?

      ssh_key_data = keydata_from_file(row['ssh_key_file_name'])
      public_object_for_row  = Metasploit::Credential::Public.where(username: row['username']).first_or_create
      private_object_for_row = Metasploit::Credential::SSHKey.where(data: ssh_key_data)

      new_core         = Metasploit::Credential::Core.new
      new_core.public  = public_object_for_row
      new_core.private = private_object_for_row
      new_core.save!
    end
  end

  # The key data inside the file at +key_file_name+
  #
  # @return [String]
  def key_data_from_file(key_file_name)
    full_key_file_path = "#{File.dirname(data.path)}/#{key_file_name}"
    File.open(full_key_file_path, 'r').read
  end
end