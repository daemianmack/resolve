# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080926010230) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.integer  "priority",     :default => 3, :null => false
    t.text     "description"
    t.text     "extra_fields"
    t.date     "wanted_on"
    t.date     "dropdead_on"
    t.integer  "category_id"
    t.integer  "requester_id"
    t.integer  "fixer_id"
    t.integer  "lock_version", :default => 0, :null => false
    t.datetime "finished_at"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items_watchers", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "user_id"
  end

  create_table "permissions", :force => true do |t|
    t.string   "role"
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.text     "content"
    t.text     "emailed_to"
    t.text     "emailed_cc"
    t.text     "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                            :default => 0, :null => false
  end

end
