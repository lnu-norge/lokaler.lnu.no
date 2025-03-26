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

ActiveRecord::Schema[7.2].define(version: 2025_03_26_102624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_personal_space_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "personal_space_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["personal_space_list_id"], name: "index_active_personal_space_lists_on_personal_space_list_id"
    t.index ["user_id"], name: "index_active_personal_space_lists_on_user_id", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "facilities", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
  end

  create_table "facilities_categories", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "facility_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_category_id"], name: "index_facilities_categories_on_facility_category_id"
    t.index ["facility_id"], name: "index_facilities_categories_on_facility_id"
  end

  create_table "facility_categories", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_facility_categories_on_parent_id"
  end

  create_table "facility_reviews", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "space_id", null: false
    t.bigint "user_id", null: false
    t.integer "experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_facility_reviews_on_facility_id"
    t.index ["space_id", "facility_id"], name: "index_facility_reviews_on_space_id_and_facility_id"
    t.index ["space_id", "user_id", "facility_id"], name: "index_facility_reviews_on_space_id_and_user_id_and_facility_id", unique: true
    t.index ["space_id"], name: "index_facility_reviews_on_space_id"
    t.index ["user_id"], name: "index_facility_reviews_on_user_id"
  end

  create_table "geographical_area_types", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_geographical_area_types_on_parent_id"
  end

  create_table "geographical_areas", force: :cascade do |t|
    t.string "name"
    t.boolean "filterable", default: true
    t.integer "order"
    t.geometry "geo_area", limit: {:srid=>0, :type=>"geometry"}, null: false
    t.bigint "parent_id"
    t.bigint "geographical_area_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unique_id_for_external_source"
    t.string "external_source"
    t.index ["geo_area"], name: "index_geographical_areas_on_geo_area", using: :gist
    t.index ["geographical_area_type_id"], name: "index_geographical_areas_on_geographical_area_type_id"
    t.index ["parent_id"], name: "index_geographical_areas_on_parent_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "credits"
    t.string "caption"
    t.bigint "space_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id"], name: "index_images_on_space_id"
  end

  create_table "personal_data_on_space_in_lists", primary_key: ["space_id", "personal_space_list_id"], force: :cascade do |t|
    t.integer "contact_status", default: 0, null: false
    t.text "personal_notes"
    t.bigint "space_id", null: false
    t.bigint "personal_space_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["personal_space_list_id"], name: "idx_on_personal_space_list_id_d490dca030"
    t.index ["space_id", "personal_space_list_id"], name: "index_personal_data_on_space_in_lists_on_space_and_list", unique: true
    t.index ["space_id"], name: "index_personal_data_on_space_in_lists_on_space_id"
  end

  create_table "personal_space_lists", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.boolean "shared_with_public", default: false
    t.integer "space_count", default: 0
    t.integer "space_not_contacted_count", default: 0
    t.integer "space_said_no_count", default: 0
    t.integer "space_said_maybe_count", default: 0
    t.integer "space_said_yes_count", default: 0
    t.index ["user_id"], name: "index_personal_space_lists_on_user_id"
  end

  create_table "personal_space_lists_shared_with_mes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "personal_space_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["personal_space_list_id"], name: "idx_on_personal_space_list_id_d87a69044d"
    t.index ["user_id"], name: "index_personal_space_lists_shared_with_mes_on_user_id"
  end

  create_table "personal_space_lists_spaces", id: false, force: :cascade do |t|
    t.bigint "personal_space_list_id", null: false
    t.bigint "space_id", null: false
    t.index ["personal_space_list_id"], name: "index_personal_space_lists_spaces_on_personal_space_list_id"
    t.index ["space_id"], name: "index_personal_space_lists_spaces_on_space_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "comment"
    t.decimal "star_rating", precision: 2, scale: 1
    t.bigint "user_id", null: false
    t.bigint "space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization", default: "", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_group_id"], name: "index_space_contacts_on_space_group_id"
    t.index ["space_id"], name: "index_space_contacts_on_space_id"
  end

  create_table "space_facilities", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "space_id", null: false
    t.integer "experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.boolean "relevant", default: false
    t.integer "score", default: 0
    t.index ["facility_id"], name: "index_space_facilities_on_facility_id"
    t.index ["space_id", "facility_id"], name: "index_space_facilities_on_space_id_and_facility_id", unique: true
    t.index ["space_id"], name: "index_space_facilities_on_space_id"
  end

  create_table "space_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
  end

  create_table "space_types", force: :cascade do |t|
    t.string "type_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "space_types_facilities", force: :cascade do |t|
    t.bigint "space_type_id", null: false
    t.bigint "facility_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_space_types_facilities_on_facility_id"
    t.index ["space_type_id", "facility_id"], name: "index_space_types_facilities_on_space_type_id_and_facility_id", unique: true
    t.index ["space_type_id"], name: "index_space_types_facilities_on_space_type_id"
  end

  create_table "space_types_relations", force: :cascade do |t|
    t.bigint "space_type_id", null: false
    t.bigint "space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id"], name: "index_space_types_relations_on_space_id"
    t.index ["space_type_id"], name: "index_space_types_relations_on_space_type_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.string "address"
    t.decimal "lat"
    t.decimal "lng"
    t.bigint "space_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.string "organization_number"
    t.string "post_number"
    t.string "post_address"
    t.string "municipality_code"
    t.decimal "star_rating", precision: 2, scale: 1
    t.text "location_description"
    t.geography "geo_point", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}, null: false
    t.bigint "fylke_id"
    t.bigint "kommune_id"
    t.index ["fylke_id"], name: "index_spaces_on_fylke_id"
    t.index ["geo_point"], name: "index_spaces_on_geo_point", using: :gist
    t.index ["kommune_id"], name: "index_spaces_on_kommune_id"
    t.index ["space_group_id"], name: "index_spaces_on_space_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "organization_name"
    t.string "remember_token", limit: 20
    t.boolean "organization_boolean"
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
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_personal_space_lists", "personal_space_lists"
  add_foreign_key "active_personal_space_lists", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "facilities_categories", "facilities"
  add_foreign_key "facilities_categories", "facility_categories"
  add_foreign_key "facility_reviews", "facilities"
  add_foreign_key "facility_reviews", "spaces"
  add_foreign_key "facility_reviews", "users"
  add_foreign_key "geographical_area_types", "geographical_area_types", column: "parent_id"
  add_foreign_key "geographical_areas", "geographical_area_types"
  add_foreign_key "geographical_areas", "geographical_areas", column: "parent_id"
  add_foreign_key "personal_data_on_space_in_lists", "personal_space_lists"
  add_foreign_key "personal_data_on_space_in_lists", "spaces"
  add_foreign_key "personal_space_lists_shared_with_mes", "personal_space_lists"
  add_foreign_key "personal_space_lists_shared_with_mes", "users"
  add_foreign_key "reviews", "spaces"
  add_foreign_key "reviews", "users"
  add_foreign_key "space_contacts", "space_groups"
  add_foreign_key "space_contacts", "spaces"
  add_foreign_key "space_facilities", "facilities"
  add_foreign_key "space_facilities", "spaces"
  add_foreign_key "space_types_facilities", "facilities"
  add_foreign_key "space_types_facilities", "space_types"
  add_foreign_key "space_types_relations", "space_types"
  add_foreign_key "space_types_relations", "spaces"
  add_foreign_key "spaces", "geographical_areas", column: "fylke_id"
  add_foreign_key "spaces", "geographical_areas", column: "kommune_id"
  add_foreign_key "spaces", "space_groups"
end
