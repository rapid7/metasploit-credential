# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140410161611) do

  create_table "metasploit_credential_privates", :force => true do |t|
    t.string   "type",       :null => false
    t.text     "data",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "metasploit_credential_privates", ["type", "data"], :name => "index_metasploit_credential_privates_on_type_and_data", :unique => true

  create_table "metasploit_credential_publics", :force => true do |t|
    t.string   "username",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "metasploit_credential_publics", ["username"], :name => "index_metasploit_credential_publics_on_username", :unique => true

  create_table "metasploit_credential_realms", :force => true do |t|
    t.string   "key",        :null => false
    t.string   "value",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "metasploit_credential_realms", ["key", "value"], :name => "index_metasploit_credential_realms_on_key_and_value", :unique => true

end
