# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_09_101806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "aggregated_facility_reviews", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "space_id", null: false
    t.integer "experience"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["facility_id"], name: "index_aggregated_facility_reviews_on_facility_id"
    t.index ["space_id"], name: "index_aggregated_facility_reviews_on_space_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon"
    t.bigint "facility_category_id"
    t.index ["facility_category_id"], name: "index_facilities_on_facility_category_id"
  end

  create_table "facility_categories", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "facility_reviews", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "space_id", null: false
    t.bigint "user_id", null: false
    t.bigint "review_id"
    t.integer "experience"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["facility_id"], name: "index_facility_reviews_on_facility_id"
    t.index ["review_id", "facility_id"], name: "index_facility_reviews_on_review_id_and_facility_id", unique: true
    t.index ["review_id"], name: "index_facility_reviews_on_review_id"
    t.index ["space_id"], name: "index_facility_reviews_on_space_id"
    t.index ["user_id"], name: "index_facility_reviews_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "credits"
    t.string "caption"
    t.bigint "space_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["space_id"], name: "index_images_on_space_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "orgnr"
    t.string "website"
    t.string "logo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.index ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id", unique: true
    t.index ["user_id", "organization_id"], name: "index_organizations_users_on_user_id_and_organization_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.string "title"
    t.string "comment"
    t.integer "price"
    t.decimal "star_rating", precision: 2, scale: 1
    t.bigint "user_id", null: false
    t.bigint "space_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "organization_id"
    t.integer "how_much"
    t.string "how_much_custom"
    t.integer "how_long"
    t.string "how_long_custom"
    t.integer "type_of_contact"
    t.index ["organization_id"], name: "index_reviews_on_organization_id"
    t.index ["space_id"], name: "index_reviews_on_space_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "space_contacts", force: :cascade do |t|
    t.string "title"
    t.string "telephone"
    t.string "telephone_opening_hours"
    t.string "email"
    t.string "url"
    t.text "description"
    t.integer "priority"
    t.bigint "space_id"
    t.bigint "space_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["space_group_id"], name: "index_space_contacts_on_space_group_id"
    t.index ["space_id"], name: "index_space_contacts_on_space_id"
  end

  create_table "space_groups", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
  end

  create_table "space_types", force: :cascade do |t|
    t.string "type_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "spaces", force: :cascade do |t|
    t.string "address"
    t.decimal "lat"
    t.decimal "lng"
    t.bigint "space_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "space_type_id"
    t.string "title", null: false
    t.string "organization_number"
    t.string "post_number"
    t.string "post_address"
    t.string "municipality_code"
    t.decimal "star_rating", precision: 2, scale: 1
    t.string "url"
    t.index ["space_group_id"], name: "index_spaces_on_space_group_id"
    t.index ["space_type_id"], name: "index_spaces_on_space_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type"
    t.string "{:null=>false}"
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "aggregated_facility_reviews", "facilities"
  add_foreign_key "aggregated_facility_reviews", "spaces"
  add_foreign_key "facilities", "facility_categories"
  add_foreign_key "facility_reviews", "facilities"
  add_foreign_key "facility_reviews", "reviews"
  add_foreign_key "facility_reviews", "spaces"
  add_foreign_key "facility_reviews", "users"
  add_foreign_key "reviews", "organizations"
  add_foreign_key "reviews", "spaces"
  add_foreign_key "reviews", "users"
  add_foreign_key "space_contacts", "space_groups"
  add_foreign_key "space_contacts", "spaces"
  add_foreign_key "spaces", "space_groups"
  add_foreign_key "spaces", "space_types"
end
