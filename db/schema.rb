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

ActiveRecord::Schema[7.0].define(version: 2025_07_10_160300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "adminpack"
  enable_extension "autoinc"
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "cube"
  enable_extension "dblink"
  enable_extension "dict_int"
  enable_extension "dict_xsyn"
  enable_extension "earthdistance"
  enable_extension "file_fdw"
  enable_extension "fuzzystrmatch"
  enable_extension "hstore"
  enable_extension "insert_username"
  enable_extension "intagg"
  enable_extension "intarray"
  enable_extension "isn"
  enable_extension "lo"
  enable_extension "ltree"
  enable_extension "moddatetime"
  enable_extension "pageinspect"
  enable_extension "pg_buffercache"
  enable_extension "pg_freespacemap"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "pgrowlocks"
  enable_extension "pgstattuple"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "postgis_tiger_geocoder"
  enable_extension "postgis_topology"
  enable_extension "postgres_fdw"
  enable_extension "refint"
  enable_extension "seg"
  enable_extension "sslinfo"
  enable_extension "tablefunc"
  enable_extension "tcn"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"
  enable_extension "xml2"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addr", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.bigint "tlid"
    t.string "fromhn", limit: 12
    t.string "tohn", limit: 12
    t.string "side", limit: 1
    t.string "zip", limit: 5
    t.string "plus4", limit: 4
    t.string "fromtyp", limit: 1
    t.string "totyp", limit: 1
    t.integer "fromarmid"
    t.integer "toarmid"
    t.string "arid", limit: 22
    t.string "mtfcc", limit: 5
    t.string "statefp", limit: 2
    t.index ["tlid", "statefp"], name: "idx_tiger_addr_tlid_statefp"
    t.index ["zip"], name: "idx_tiger_addr_zip"
  end

# Could not dump table "addrfeat" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "authors", force: :cascade do |t|
    t.string "nickname"
    t.string "bio"
    t.string "website"
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_authors_on_store_id"
  end

# Could not dump table "bg" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "booking_contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.string "instagram_user_id"
    t.string "instagram_handle"
  end

  create_table "booking_messages", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "user_id", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instagram_message_id"
    t.string "instagram_sender_username"
    t.string "instagram_sender_full_name"
    t.string "instagram_sender_id"
    t.datetime "instagram_timestamp"
    t.index ["booking_id"], name: "index_booking_messages_on_booking_id"
    t.index ["user_id"], name: "index_booking_messages_on_user_id"
  end

  create_table "booking_steps", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "step_type"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_steps_on_booking_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "gig_id"
    t.bigint "booking_contact_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id"
    t.index ["booking_contact_id"], name: "index_bookings_on_booking_contact_id"
    t.index ["gig_id"], name: "index_bookings_on_gig_id"
    t.index ["venue_id"], name: "index_bookings_on_venue_id"
  end

  create_table "carousel_cards", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "position_x"
    t.integer "position_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_categories_on_store_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.bigint "cover_id"
    t.index ["cover_id"], name: "index_collections_on_cover_id"
    t.index ["store_id"], name: "index_collections_on_store_id"
  end

# Could not dump table "county" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "county_lookup", primary_key: ["st_code", "co_code"], force: :cascade do |t|
    t.integer "st_code", null: false
    t.string "state", limit: 2
    t.integer "co_code", null: false
    t.string "name", limit: 90
    t.index "soundex((name)::text)", name: "county_lookup_name_idx"
    t.index ["state"], name: "county_lookup_state_idx"
  end

  create_table "countysub_lookup", primary_key: ["st_code", "co_code", "cs_code"], force: :cascade do |t|
    t.integer "st_code", null: false
    t.string "state", limit: 2
    t.integer "co_code", null: false
    t.string "county", limit: 90
    t.integer "cs_code", null: false
    t.string "name", limit: 90
    t.index "soundex((name)::text)", name: "countysub_lookup_name_idx"
    t.index ["state"], name: "countysub_lookup_state_idx"
  end

# Could not dump table "cousub" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "direction_lookup", primary_key: "name", id: { type: :string, limit: 20 }, force: :cascade do |t|
    t.string "abbrev", limit: 3
    t.index ["abbrev"], name: "direction_lookup_abbrev_idx"
  end

# Could not dump table "edges" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "events", force: :cascade do |t|
    t.text "data"
    t.string "source"
    t.string "processing_errors"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "faces" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "featnames", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.bigint "tlid"
    t.string "fullname", limit: 100
    t.string "name", limit: 100
    t.string "predirabrv", limit: 15
    t.string "pretypabrv", limit: 50
    t.string "prequalabr", limit: 15
    t.string "sufdirabrv", limit: 15
    t.string "suftypabrv", limit: 50
    t.string "sufqualabr", limit: 15
    t.string "predir", limit: 2
    t.string "pretyp", limit: 3
    t.string "prequal", limit: 2
    t.string "sufdir", limit: 2
    t.string "suftyp", limit: 3
    t.string "sufqual", limit: 2
    t.string "linearid", limit: 22
    t.string "mtfcc", limit: 5
    t.string "paflag", limit: 1
    t.string "statefp", limit: 2
    t.index "lower((name)::text)", name: "idx_tiger_featnames_lname"
    t.index "soundex((name)::text)", name: "idx_tiger_featnames_snd_name"
    t.index ["tlid", "statefp"], name: "idx_tiger_featnames_tlid_statefp"
  end

  create_table "fees", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_fees_on_order_id"
  end

  create_table "filterable_views", force: :cascade do |t|
    t.string "title", null: false
    t.json "filters", default: [], null: false
    t.string "conjonction", default: "and", null: false
    t.json "sort", default: {}, null: false
    t.string "model", null: false
    t.string "context_name"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_filterable_views_on_owner"
  end

  create_table "geocode_settings", primary_key: "name", id: :text, force: :cascade do |t|
    t.text "setting"
    t.text "unit"
    t.text "category"
    t.text "short_desc"
  end

  create_table "geocode_settings_default", primary_key: "name", id: :text, force: :cascade do |t|
    t.text "setting"
    t.text "unit"
    t.text "category"
    t.text "short_desc"
  end

  create_table "gigs", force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.interval "duration"
    t.decimal "price"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_authors", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_item_authors_on_author_id"
    t.index ["item_id"], name: "index_item_authors_on_item_id"
  end

  create_table "item_specifications", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "specification_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_specifications_on_item_id"
    t.index ["specification_id"], name: "index_item_specifications_on_specification_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents"
    t.string "price_currency"
    t.bigint "store_id", null: false
    t.integer "stock"
    t.integer "weight"
    t.integer "length"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.bigint "category_id", null: false
    t.string "status", default: "active"
    t.bigint "collection_id"
    t.string "format"
    t.string "pre_sale_url"
    t.string "sub_name"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["collection_id"], name: "index_items_on_collection_id"
    t.index ["store_id"], name: "index_items_on_store_id"
  end

  create_table "layer", primary_key: ["topology_id", "layer_id"], force: :cascade do |t|
    t.integer "topology_id", null: false
    t.integer "layer_id", null: false
    t.string "schema_name", null: false
    t.string "table_name", null: false
    t.string "feature_column", null: false
    t.integer "feature_type", null: false
    t.integer "level", default: 0, null: false
    t.integer "child_id"
    t.index ["schema_name", "table_name", "feature_column"], name: "layer_schema_name_table_name_feature_column_key", unique: true
  end

  create_table "loader_lookuptables", primary_key: "lookup_name", id: { type: :text, comment: "This is the table name to inherit from and suffix of resulting output table -- how the table will be named --  edges here would mean -- ma_edges , pa_edges etc. except in the case of national tables. national level tables have no prefix" }, force: :cascade do |t|
    t.integer "process_order", default: 1000, null: false
    t.text "table_name", comment: "suffix of the tables to load e.g.  edges would load all tables like *edges.dbf(shp)  -- so tl_2010_42129_edges.dbf .  "
    t.boolean "single_mode", default: true, null: false
    t.boolean "load", default: true, null: false, comment: "Whether or not to load the table.  For states and zcta5 (you may just want to download states10, zcta510 nationwide file manually) load your own into a single table that inherits from tiger.states, tiger.zcta5.  You'll get improved performance for some geocoding cases."
    t.boolean "level_county", default: false, null: false
    t.boolean "level_state", default: false, null: false
    t.boolean "level_nation", default: false, null: false, comment: "These are tables that contain all data for the whole US so there is just a single file"
    t.text "post_load_process"
    t.boolean "single_geom_mode", default: false
    t.string "insert_mode", limit: 1, default: "c", null: false
    t.text "pre_load_process"
    t.text "columns_exclude", comment: "List of columns to exclude as an array. This is excluded from both input table and output table and rest of columns remaining are assumed to be in same order in both tables. gid, geoid,cpi,suffix1ce are excluded if no columns are specified.", array: true
    t.text "website_root_override", comment: "Path to use for wget instead of that specified in year table.  Needed currently for zcta where they release that only for 2000 and 2010"
  end

  create_table "loader_platform", primary_key: "os", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.text "declare_sect"
    t.text "pgbin"
    t.text "wget"
    t.text "unzip_command"
    t.text "psql"
    t.text "path_sep"
    t.text "loader"
    t.text "environ_set_command"
    t.text "county_process_command"
  end

  create_table "loader_variables", primary_key: "tiger_year", id: { type: :string, limit: 4 }, force: :cascade do |t|
    t.text "website_root"
    t.text "staging_fold"
    t.text "data_schema"
    t.text "staging_schema"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.string "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "checkout_session_id"
    t.bigint "store_id", null: false
    t.integer "fees_cents", default: 0, null: false
    t.string "fees_currency", default: "EUR", null: false
    t.index ["store_id"], name: "index_orders_on_store_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pagc_gaz", id: :serial, force: :cascade do |t|
    t.integer "seq"
    t.text "word"
    t.text "stdword"
    t.integer "token"
    t.boolean "is_custom", default: true, null: false
  end

  create_table "pagc_lex", id: :serial, force: :cascade do |t|
    t.integer "seq"
    t.text "word"
    t.text "stdword"
    t.integer "token"
    t.boolean "is_custom", default: true, null: false
  end

  create_table "pagc_rules", id: :serial, force: :cascade do |t|
    t.text "rule"
    t.boolean "is_custom", default: true
  end

# Could not dump table "place" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "place_lookup", primary_key: ["st_code", "pl_code"], force: :cascade do |t|
    t.integer "st_code", null: false
    t.string "state", limit: 2
    t.integer "pl_code", null: false
    t.string "name", limit: 90
    t.index "soundex((name)::text)", name: "place_lookup_name_idx"
    t.index ["state"], name: "place_lookup_state_idx"
  end

  create_table "secondary_unit_lookup", primary_key: "name", id: { type: :string, limit: 20 }, force: :cascade do |t|
    t.string "abbrev", limit: 5
    t.index ["abbrev"], name: "secondary_unit_lookup_abbrev_idx"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shippings", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "api_shipping_id"
    t.integer "api_service_point_id"
    t.string "api_tracking_number"
    t.string "api_tracking_url"
    t.string "api_method_name"
    t.integer "parcel_id"
    t.string "method_carrier"
    t.string "service_point_address"
    t.string "service_point_name"
    t.integer "cost_cents", default: 0, null: false
    t.string "cost_currency", default: "EUR", null: false
    t.string "address"
    t.string "country"
    t.string "city"
    t.string "postal_code"
    t.string "weight"
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "api_error"
    t.string "street_number"
    t.string "address_first_line"
    t.string "address_second_line"
    t.string "status", default: "pending"
    t.index ["order_id"], name: "index_shippings_on_order_id"
  end

  create_table "social_campagnes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "active", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_social_campagnes_on_user_id"
  end

  create_table "social_targets", force: :cascade do |t|
    t.string "name", null: false
    t.string "kind", null: false
    t.string "cursor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "social_campagne_id"
    t.index ["social_campagne_id"], name: "index_social_targets_on_social_campagne_id"
  end

  create_table "spatial_ref_sys", primary_key: "srid", id: :integer, default: nil, force: :cascade do |t|
    t.string "auth_name", limit: 256
    t.integer "auth_srid"
    t.string "srtext", limit: 2048
    t.string "proj4text", limit: 2048
    t.check_constraint "srid > 0 AND srid <= 998999", name: "spatial_ref_sys_srid_check"
  end

  create_table "specifications", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.index ["store_id"], name: "index_specifications_on_store_id"
  end

# Could not dump table "state" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "state_lookup", primary_key: "st_code", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 40
    t.string "abbrev", limit: 3
    t.string "statefp", limit: 2
    t.index ["abbrev"], name: "state_lookup_abbrev_key", unique: true
    t.index ["name"], name: "state_lookup_name_key", unique: true
    t.index ["statefp"], name: "state_lookup_statefp_key", unique: true
  end

  create_table "store_order_items", force: :cascade do |t|
    t.string "orderable_type", null: false
    t.bigint "orderable_id", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_order_id", null: false
    t.integer "endi_line_id"
    t.index ["store_order_id"], name: "index_store_order_items_on_store_order_id"
  end

  create_table "store_orders", force: :cascade do |t|
    t.string "status", default: "pending"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.bigint "store_id", null: false
    t.string "ref"
    t.date "date"
    t.integer "endi_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "api_error"
    t.index ["store_id"], name: "index_store_orders_on_store_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.string "slug"
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_image"
    t.string "instagram_url"
    t.string "facebook_url"
    t.string "about_text"
    t.boolean "holiday", default: true
    t.string "holiday_sentence", default: "Boutique en vacances"
    t.boolean "display_stock", default: false
    t.text "postmark_key"
    t.text "mail_body"
    t.text "sendcloud_private_key"
    t.text "sendcloud_public_key"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "address"
    t.float "rates", default: 0.2
    t.string "stripe_account_id"
    t.boolean "charges_enable", default: false
    t.boolean "payouts_enable", default: false
    t.boolean "details_submitted", default: false
    t.string "stripe_subscription_id"
    t.string "subscription_status", default: "pending", null: false
    t.string "stripe_checkout_session_id"
    t.text "endi_auth"
    t.integer "endi_id"
    t.boolean "filters", default: true
    t.index ["admin_id"], name: "index_stores_on_admin_id"
    t.index ["slug"], name: "index_stores_on_slug", unique: true
    t.index ["stripe_subscription_id"], name: "index_stores_on_stripe_subscription_id", unique: true
  end

  create_table "street_type_lookup", primary_key: "name", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "abbrev", limit: 50
    t.boolean "is_hw", default: false, null: false
    t.index ["abbrev"], name: "street_type_lookup_abbrev_idx"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "date"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "tabblock" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "tabblock20" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4269)' for column 'the_geom'

  create_table "topology", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "srid", null: false
    t.float "precision", null: false
    t.boolean "hasz", default: false, null: false
    t.index ["name"], name: "topology_name_key", unique: true
  end

# Could not dump table "tract" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "avater_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "phone"
    t.string "customer_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "instagram_username"
    t.string "instagram_password"
    t.string "instagram_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.string "phone"
    t.string "email"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.string "instagram_user_id"
    t.string "instagram_handle"
  end

# Could not dump table "zcta5" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "zip_lookup", primary_key: "zip", id: :integer, default: nil, force: :cascade do |t|
    t.integer "st_code"
    t.string "state", limit: 2
    t.integer "co_code"
    t.string "county", limit: 90
    t.integer "cs_code"
    t.string "cousub", limit: 90
    t.integer "pl_code"
    t.string "place", limit: 90
    t.integer "cnt"
  end

  create_table "zip_lookup_all", id: false, force: :cascade do |t|
    t.integer "zip"
    t.integer "st_code"
    t.string "state", limit: 2
    t.integer "co_code"
    t.string "county", limit: 90
    t.integer "cs_code"
    t.string "cousub", limit: 90
    t.integer "pl_code"
    t.string "place", limit: 90
    t.integer "cnt"
  end

  create_table "zip_lookup_base", primary_key: "zip", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "state", limit: 40
    t.string "county", limit: 90
    t.string "city", limit: 90
    t.string "statefp", limit: 2
  end

  create_table "zip_state", primary_key: ["zip", "stusps"], force: :cascade do |t|
    t.string "zip", limit: 5, null: false
    t.string "stusps", limit: 2, null: false
    t.string "statefp", limit: 2
  end

  create_table "zip_state_loc", primary_key: ["zip", "stusps", "place"], force: :cascade do |t|
    t.string "zip", limit: 5, null: false
    t.string "stusps", limit: 2, null: false
    t.string "statefp", limit: 2
    t.string "place", limit: 100, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "authors", "stores"
  add_foreign_key "booking_messages", "bookings"
  add_foreign_key "booking_messages", "users"
  add_foreign_key "booking_steps", "bookings"
  add_foreign_key "bookings", "booking_contacts"
  add_foreign_key "bookings", "gigs"
  add_foreign_key "bookings", "venues"
  add_foreign_key "categories", "stores"
  add_foreign_key "collections", "items", column: "cover_id"
  add_foreign_key "collections", "stores"
  add_foreign_key "fees", "orders"
  add_foreign_key "item_authors", "authors"
  add_foreign_key "item_authors", "items"
  add_foreign_key "item_specifications", "items"
  add_foreign_key "item_specifications", "specifications"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "collections"
  add_foreign_key "items", "stores"
  add_foreign_key "layer", "topology", name: "layer_topology_id_fkey"
  add_foreign_key "order_items", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "stores"
  add_foreign_key "orders", "users"
  add_foreign_key "shippings", "orders"
  add_foreign_key "social_campagnes", "users"
  add_foreign_key "social_targets", "social_campagnes"
  add_foreign_key "specifications", "stores"
  add_foreign_key "store_order_items", "store_orders"
  add_foreign_key "store_orders", "stores"
  add_foreign_key "stores", "users", column: "admin_id"
end
