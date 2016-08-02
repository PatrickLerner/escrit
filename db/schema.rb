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

ActiveRecord::Schema.define(version: 20160626085342) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "compliments", force: :cascade do |t|
    t.text     "value"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", force: :cascade do |t|
    t.integer  "word_id"
    t.integer  "token_id"
    t.integer  "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_id"], name: "index_entries_on_token_id", using: :btree
    t.index ["word_id", "token_id"], name: "index_entries_on_word_id_and_token_id", unique: true, using: :btree
    t.index ["word_id"], name: "index_entries_on_word_id", using: :btree
  end

  create_table "languages", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "voice"
    t.string   "voice_rate"
    t.string   "code"
    t.index ["code"], name: "index_languages_on_code", unique: true, using: :btree
  end

  create_table "notes", force: :cascade do |t|
    t.string   "value"
    t.integer  "word_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_id"], name: "index_notes_on_word_id", using: :btree
  end

  create_table "replacements", force: :cascade do |t|
    t.string   "value",       limit: 255
    t.string   "replacement", limit: 255
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["language_id"], name: "index_replacements_on_language_id", using: :btree
  end

  create_table "services", force: :cascade do |t|
    t.text     "name"
    t.text     "short_name"
    t.text     "url"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "enabled"
    t.index ["language_id"], name: "index_services_on_language_id", using: :btree
  end

  create_table "texts", force: :cascade do |t|
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
    t.datetime "last_opened_at"
    t.string   "uuid"
    t.index ["category_id"], name: "index_texts_on_category_id", using: :btree
    t.index ["language_id"], name: "index_texts_on_language_id", using: :btree
    t.index ["uuid"], name: "index_texts_on_uuid", unique: true, using: :btree
  end

  create_table "texts_tokens", id: false, force: :cascade do |t|
    t.integer "text_id"
    t.integer "token_id"
    t.index ["text_id"], name: "index_texts_tokens_on_text_id", using: :btree
    t.index ["token_id"], name: "index_texts_tokens_on_token_id", using: :btree
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_tokens_on_value", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
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
    t.text     "name"
    t.text     "about"
    t.integer  "native_language_id"
    t.integer  "audio_rate"
    t.string   "role"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["native_language_id"], name: "index_users_on_native_language_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
  end

  create_table "words", force: :cascade do |t|
    t.string   "value"
    t.integer  "language_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["language_id"], name: "index_words_on_language_id", using: :btree
    t.index ["user_id"], name: "index_words_on_user_id", using: :btree
    t.index ["value", "language_id", "user_id"], name: "index_words_on_value_and_language_id_and_user_id", unique: true, using: :btree
  end

  add_foreign_key "entries", "tokens"
  add_foreign_key "entries", "words"
  add_foreign_key "notes", "words"
  add_foreign_key "words", "languages"
  add_foreign_key "words", "users"
end
