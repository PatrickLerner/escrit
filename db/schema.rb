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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151207162816) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buddies", force: true do |t|
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buddies", ["destination_id"], name: "index_buddies_on_destination_id", using: :btree
  add_index "buddies", ["origin_id"], name: "index_buddies_on_origin_id", using: :btree

  create_table "categories", force: true do |t|
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
  end

  add_index "categories", ["language_id"], name: "index_categories_on_language_id", using: :btree

  create_table "compliments", force: true do |t|
    t.text     "value"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: true do |t|
    t.string   "value"
    t.integer  "rating"
    t.integer  "word_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree
  add_index "notes", ["word_id"], name: "index_notes_on_word_id", using: :btree

  create_table "occurrences", force: true do |t|
    t.integer  "word_id"
    t.integer  "text_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "occurrences", ["text_id"], name: "index_occurrences_on_text_id", using: :btree
  add_index "occurrences", ["word_id"], name: "index_occurrences_on_word_id", using: :btree

  create_table "replacements", force: true do |t|
    t.string   "value"
    t.string   "replacement"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "replacements", ["language_id"], name: "index_replacements_on_language_id", using: :btree

  create_table "services", force: true do |t|
    t.text     "name"
    t.text     "short_name"
    t.text     "url"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "enabled"
  end

  add_index "services", ["language_id"], name: "index_services_on_language_id", using: :btree

  create_table "texts", force: true do |t|
    t.text     "title"
    t.text     "content"
    t.text     "category"
    t.boolean  "completed"
    t.integer  "word_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
    t.integer  "category_id"
    t.boolean  "hidden"
    t.integer  "user_id"
    t.boolean  "public"
  end

  add_index "texts", ["category_id"], name: "index_texts_on_category_id", using: :btree
  add_index "texts", ["language_id"], name: "index_texts_on_language_id", using: :btree

  create_table "users", force: true do |t|
    t.text     "email",                  default: "", null: false
    t.text     "encrypted_password",     default: "", null: false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.text     "name"
    t.text     "about"
    t.integer  "native_language_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["native_language_id"], name: "index_users_on_native_language_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "words", force: true do |t|
    t.text     "value"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
