class CreateMetasploitCredentialOriginImports < ActiveRecord::Migration
  def change
    create_table :metasploit_credential_origin_imports do |t|
      #
      # Columns
      #

      t.text :filename, null: false

      #
      # Foreign Keys
      #

      t.references :task, null: false

      #
      # Timestamps
      #

      t.timestamps
    end

    #
    # Foreign Key Indices
    #

    add_index :metasploit_credential_origin_imports, :task_id
  end
end
