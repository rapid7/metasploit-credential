class CreateIndexOnPrivateDataAndTypeForPkcs12 < ActiveRecord::Migration[6.1]
  def up
    # Drop the existing index created by 20161107153145_recreate_index_on_private_data_and_type.rb, and recreate it
    # with Metasploit::Credential::Pkcs12 ignored
    remove_index :metasploit_credential_privates, [:type, :data], if_exists: true
    change_table :metasploit_credential_privates do |t|
      t.index [:type, :data],
              unique: true,
              where: "NOT (type = 'Metasploit::Credential::SSHKey' or type = 'Metasploit::Credential::Pkcs12')"
    end

    # Create a new index similar to 20161107203710_create_index_on_private_data_and_type_for_ssh_key.rb
    sql = <<~EOF
      CREATE UNIQUE INDEX "index_metasploit_credential_privates_on_type_and_data_pkcs12" ON
      "metasploit_credential_privates" ("type", decode(md5(data), 'hex'))
      WHERE type in ('Metasploit::Credential::Pkcs12')
    EOF
    execute(sql)
  end

  def down
    change_table :metasploit_credential_privates do |t|
      t.index [:type, :data],
              unique: true,
              where: "NOT (type = 'Metasploit::Credential::SSHKey' or type = 'Metasploit::Credential::Pkcs12')"
    end

    remove_index :index_metasploit_credential_privates_on_type_and_data_sshkey, if_exists: true
  end
end
