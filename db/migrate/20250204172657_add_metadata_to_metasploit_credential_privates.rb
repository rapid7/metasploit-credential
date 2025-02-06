class AddMetadataToMetasploitCredentialPrivates < ActiveRecord::Migration[7.0]
  def change
    add_column :metasploit_credential_privates, :metadata, :jsonb, null: false, default: {}
  end
end
