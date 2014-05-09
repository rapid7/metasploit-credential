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
  # Attributes
  #


  #
  # Instance Methods
  #

  # Perform the import from the data in {#csv_object}
  # @return [void]
  def import!
    realms = Hash.new  # A Hash of Realm objects that we create or find as we encounter new ones
    csv_object.each do |row|
      next if row.header_row?

      realm_key   = row['realm_key']
      realm_value = row['realm_value']
      if realms[realm_value].nil?
        realms[realm_value] = Metasploit::Credential::Realm.where(
                                key: realm_key,
                                value: realm_value).first_or_create
      end

      realm_object_for_row = realms[realm_value]

      public_object_for_row  = Metasploit::Credential::Public.where(
                                username: row['username']).first_or_create


      # Create an instance of whatever private type is on this row
      private_class = row['private_type'].constantize
      private_object_for_row = private_class.where(
                                data: row['private_data']).first_or_create



    end
    # for each row
    #   if Realm name matches one is in table, attach to Realm
    #   else create Realm
    #
  end


end