class AddTypetoPublic < ActiveRecord::Migration
  def change
    change_table :metasploit_credential_publics do |t|
      #
      # Single Table Inheritance
      #

      t.string :type, null: true
      Metasploit::Credential::Public.update_all(type: 'Metasploit::Credential::Username')

      change_column :type, null: false

    end
  end

end
