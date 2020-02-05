class UniqueMetasploitCredentialRealms < ActiveRecord::Migration[4.2]
  def change
    change_table :metasploit_credential_realms do |t|
      t.index [:key, :value], unique: true
    end
  end
end
