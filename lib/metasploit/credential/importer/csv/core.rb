# Creates {Metasploit::Credential::Core} objects and their associated {Metasploit::Credential::Public},
# {Metasploit::Credential::Private}, and {Metasploit::Credential::Realm} objects from a CSV file.
#
# Successful import will also create a {Metasploit::Credential::Origin::Import}
#

class Metasploit::Credential::Importer::CSV::Core < Metasploit::Credential::Importer::CSV::Base

  #
  # Constants
  #

  VALID_CSV_HEADERS = [:username, :private_type, :private_data, :realm_key, :realm_value]

  #
  # Instance Methods
  #

  # The key data inside the file at +key_file_name+
  #
  # @return [String]
  def key_data_from_file(key_file_name)
    full_key_file_path = "#{File.dirname(data.path)}/#{Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME}/#{key_file_name}"
    File.open(full_key_file_path, 'r').read
  end

  # Performs a pretty naive import from the data in {#csv_object}, allowing the import to have different private types
  # per row, and attempting to reduce database lookups by storing found or created {Metasploit::Credential::Realm}
  # objects in a lookup Hash that gets updated with every new Realm found, and then consulted in analysis of subsequent
  # rows.
  #
  # @return [void]
  def import!
    realms = Hash.new
    csv_object.each do |row|
      next if row.header_row?

      realm_key     = row['realm_key']
      realm_value   = row['realm_value']  # Use the name of the Realm as a lookup for getting the object
      private_class = row['private_type'].constantize
      private_data  = row['private_data']

      if realms[realm_value].nil?
        realms[realm_value]  = Metasploit::Credential::Realm.where(key: realm_key, value: realm_value).first_or_create
      end

      realm_object_for_row   = realms[realm_value]
      public_object_for_row  = Metasploit::Credential::Public.where(username: row['username']).first_or_create

      if ALLOWED_PRIVATE_TYPE_NAMES.include? private_class.name
        if private_class == Metasploit::Credential::SSHKey
          private_object_for_row = Metasploit::Credential::SSHKey.where(data: key_data_from_file(private_data)).first_or_create
        else
          private_object_for_row = private_class.where(data: row['private_data']).first_or_create
        end
      else
        # error condition: something unknown/unsupported in type column
      end

      create_core( public: public_object_for_row, private: private_object_for_row, realm: realm_object_for_row)
    end
  end


end