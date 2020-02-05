class AddJtrFormatToMetasploitCredentialPrivates < ActiveRecord::Migration[4.2]
  def change
    add_column :metasploit_credential_privates, :jtr_format, :string
  end
end
