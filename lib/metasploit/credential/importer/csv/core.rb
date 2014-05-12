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

  # Perform the import from the data in {#csv_object}, allowing the import to have different private types per row,
  # and attempting to reduce database lookups by storing found or created {Metasploit::Credential::Realm} objects
  # in a lookup Hash that gets updated with every new Realm found, and then consulted in analysis of subsequent rows.
  #
  # @return [void]
  def import!
    realms = Hash.new
    csv_object.each do |row|
      next if row.header_row?

      realm_key     = row['realm_key']
      realm_value   = row['realm_value']  # Use the name of the Realm as a lookup for getting the object
      private_class = row['private_type'].constantize

      if realms[realm_value].nil?
        realms[realm_value]  = Metasploit::Credential::Realm.where(key: realm_key, value: realm_value).first_or_create
      end

      realm_object_for_row   = realms[realm_value]
      public_object_for_row  = Metasploit::Credential::Public.where(username: row['username']).first_or_create
      private_object_for_row = private_class.where(data: row['private_data']).first_or_create

      # Create the final Core object with the new/old objects gathered above
      core = Metasploit::Credential::Core.new
      core.workspace = origin_import.task.workspace
      core.private   = private_object_for_row
      core.public    = public_object_for_row
      core.realm     = realm_object_for_row
      core.origin    = origin_import
      core.save!
    end
  end


end