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

ActiveRecord::Schema.define(version: 20181112130254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "actions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analysis_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analytics_dashboards", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.json "fields"
    t.integer "analysis_type_id"
    t.integer "chart_id"
    t.boolean "graph"
    t.boolean "card"
    t.integer "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_field_id"
    t.string "filter_input"
    t.string "input_value"
    t.integer "condition_field_id"
    t.string "const_field"
    t.integer "group_field_id"
    t.integer "association_id"
    t.boolean "assoc_kpi", default: false
    t.integer "dashboard_id"
    t.index ["analysis_type_id"], name: "index_analytics_dashboards_on_analysis_type_id"
    t.index ["chart_id"], name: "index_analytics_dashboards_on_chart_id"
    t.index ["project_type_id"], name: "index_analytics_dashboards_on_project_type_id"
  end

  create_table "app_configurations", id: :serial, force: :cascade do |t|
    t.integer "gisworking_initial_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blocks", id: :serial, force: :cascade do |t|
    t.integer "manzana"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_original"
    t.boolean "prefix", default: false
  end

  create_table "chains", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.integer "poi_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "objetive", default: 0
    t.integer "country_id"
    t.string "alias"
  end

  create_table "charts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_type_id"
    t.jsonb "properties"
  end

  create_table "choice_lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "value"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "cities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "department_id"
    t.string "zip"
    t.integer "proiority"
    t.point "the_geom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supplier_map", default: "osm"
  end

  create_table "dashboards", force: :cascade do |t|
    t.string "name"
    t.bigint "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type_id"], name: "index_dashboards_on_project_type_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "province_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extended_listing_loads", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.integer "success_count"
    t.integer "fail_count"
    t.integer "already_loaded_count"
    t.string "directory_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extended_listings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.integer "city_id"
    t.integer "user_id"
    t.integer "category_id"
    t.point "the_geom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "source"
    t.string "address"
    t.string "number"
    t.string "hash_value"
    t.serial "identifier", null: false
    t.integer "poi_status_id", default: 2
    t.integer "category_original_id"
    t.integer "poi_type_id"
    t.integer "poi_sub_type_id"
    t.string "website"
    t.string "email"
    t.integer "neighborhood_id"
    t.string "phone_2"
    t.string "phone_2_new"
    t.string "street_2"
    t.string "street_3"
    t.string "comments"
  end

  create_table "food_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "poi_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "generate_deliveries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geo_editions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "number"
    t.string "address"
    t.string "company"
    t.integer "city"
    t.integer "recid"
    t.string "number_door_start_original"
    t.string "number_door_start"
    t.string "number_door_end_original"
    t.string "number_door_end"
    t.string "code"
    t.point "the_geom"
    t.line "the_geom_segment"
    t.line "the_geom_segment_original"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "poi_status_id"
    t.integer "gw_div1"
    t.integer "gw_div2"
    t.integer "gw_geomainid"
    t.integer "gw_qh"
    t.integer "gw_calleid"
    t.integer "gw_pta_ini"
    t.integer "gw_pta_fin"
    t.string "gw_paridad"
    t.string "gw_status"
    t.string "paridad"
    t.integer "user_id"
    t.string "gw_street"
    t.string "gw_code"
    t.text "observations"
    t.boolean "delivered", default: false
    t.boolean "yard"
    t.boolean "wasteland"
  end

  create_table "graphics", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "width"
    t.integer "height"
    t.string "label_x_axis"
    t.string "label_y_axis_left"
    t.string "label_y_axis_right"
    t.index ["dashboard_id"], name: "index_graphics_on_dashboard_id"
  end

  create_table "graphics_properties", force: :cascade do |t|
    t.string "color"
    t.string "height"
    t.string "width"
    t.string "title"
    t.bigint "chart_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "analytics_dashboard_id"
    t.integer "graphic_id"
    t.string "label_datasets"
    t.index ["chart_id"], name: "index_graphics_properties_on_chart_id"
  end

  create_table "has_project_types", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type_id"], name: "index_has_project_types_on_project_type_id"
    t.index ["user_id"], name: "index_has_project_types_on_user_id"
  end

  create_table "load_locations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "directory_name"
  end

  create_table "p_actions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parkings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "brand"
    t.string "operator"
    t.integer "facility_type_id"
    t.integer "levels"
    t.integer "city_id"
    t.geometry "the_geom", limit: {:srid=>4326, :type=>"st_point"}
    t.geometry "the_geom_entrance", limit: {:srid=>4326, :type=>"st_point"}
    t.geometry "the_geom_exit", limit: {:srid=>4326, :type=>"st_point"}
    t.string "phone"
    t.string "website"
    t.string "detailed_pricing_model"
    t.decimal "price", precision: 10, scale: 2
    t.string "currency"
    t.string "available_payment_methods"
    t.string "regular_openning_hours"
    t.string "exceptions_opening"
    t.geometry "the_geom_area", limit: {:srid=>4326, :type=>"st_polygon"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.string "restrinctions"
    t.string "max_drive_height"
    t.string "max_drive_width"
    t.boolean "elevators", default: false
    t.boolean "escalators", default: false
    t.boolean "handicapped_accessible", default: false
    t.boolean "handicapped_parking_spaces", default: false
    t.boolean "women_parking_spaces", default: false
    t.boolean "sanitation_facilities", default: false
    t.boolean "restroom_available", default: false
    t.boolean "secure_parking", default: false
    t.boolean "security_manned", default: false
    t.boolean "electric_vehicle_charging_points", default: false
    t.boolean "connector_type", default: false
    t.boolean "number_of_connectors", default: false
    t.boolean "charge_point_operator", default: false
    t.boolean "payment_methods", default: false
    t.boolean "light", default: false
    t.boolean "motorcycle_parking_spaces", default: false
    t.boolean "family_friendly", default: false
    t.boolean "carwash", default: false
    t.boolean "parking_disc", default: false
    t.boolean "parking_ticket", default: false
    t.boolean "gate", default: false
    t.boolean "monitored", default: false
    t.boolean "none", default: false
    t.string "total_space"
    t.string "space_available"
    t.string "available"
    t.string "trend"
    t.string "total_disabled_space"
    t.string "available_disabled_space"
    t.boolean "flag", default: false
    t.string "the_geom_area_original"
    t.integer "user_id"
    t.integer "p_action_id"
    t.integer "poi_status_id"
    t.string "payment"
    t.string "parking_configuration"
    t.string "parking_capacity"
    t.string "parking_type"
    t.boolean "machine_readable"
    t.string "maximum_duration"
    t.boolean "tow_away_zone"
    t.boolean "street_sweeping"
    t.boolean "street_mall_time_market"
    t.boolean "pedestrian_zone_time"
    t.boolean "snow_route"
    t.boolean "clearway"
    t.boolean "residential"
    t.boolean "handicapped"
    t.boolean "diplomatic"
    t.boolean "media_press"
    t.boolean "other"
    t.boolean "loading_unloading_zone"
    t.boolean "drop_pick_up_zona"
    t.boolean "disabled_handicap_only"
    t.boolean "private_parking"
    t.boolean "commercial_vehicles_only"
    t.string "side_street"
    t.string "max_duration_parking_disc"
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.integer "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "poi_address_loads", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "directory_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "success_count"
    t.string "fail_count"
    t.string "already_loaded_count"
    t.integer "city_id"
    t.string "color"
  end

  create_table "poi_addresses", id: :serial, force: :cascade do |t|
    t.integer "city_id"
    t.string "street"
    t.string "number"
    t.string "neighborhood"
    t.string "block"
    t.string "house"
    t.point "the_geom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "source"
    t.string "color"
    t.string "address_complete"
    t.string "rol_number"
    t.string "city_name"
    t.string "department_name"
    t.string "province_name"
    t.string "country_name"
    t.integer "p_action_id"
    t.string "note"
    t.string "phone"
    t.string "web"
    t.string "name"
    t.integer "recid"
    t.string "name_company"
    t.string "phone_company"
    t.date "birthdate"
  end

  create_table "poi_loads", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "load_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "success_count"
    t.integer "fail_count"
    t.integer "already_loaded_count"
    t.string "directory_name"
  end

  create_table "poi_sources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "poi_statuses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "poi_sub_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "poi_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "identifier"
  end

  create_table "poi_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "pois", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "website"
    t.string "email"
    t.string "second_email"
    t.text "note"
    t.string "cel_number"
    t.string "phone"
    t.string "second_phone"
    t.string "fax"
    t.string "house_number"
    t.text "contact"
    t.integer "priority"
    t.text "location"
    t.integer "city_id"
    t.integer "chain_id"
    t.integer "food_type_id"
    t.integer "poi_source_id"
    t.integer "poi_type_id"
    t.integer "poi_sub_type_id"
    t.string "street_name"
    t.integer "street_type_id"
    t.integer "user_id"
    t.integer "poi_status_id"
    t.boolean "active", default: true
    t.boolean "deleted", default: false
    t.integer "duplicated_identifier"
    t.integer "identifier"
    t.date "control_date"
    t.geometry "the_geom", limit: {:srid=>4326, :type=>"st_point"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "poi_load_id"
    t.integer "old_identifier"
    t.string "identifier_hash"
    t.integer "p_action_id"
    t.boolean "verification", default: false
    t.string "internal_observation"
    t.integer "restaurant_type_id"
    t.date "last_update"
  end

  create_table "project_fields", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.boolean "required"
    t.boolean "cleasing_data"
    t.boolean "georeferenced"
    t.integer "project_type_id"
    t.integer "regexp_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "choice_list_id"
    t.index ["project_type_id"], name: "index_project_fields_on_project_type_id"
  end

  create_table "project_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "directory_name"
    t.index ["user_id"], name: "index_project_types_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.jsonb "properties"
    t.integer "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "properties_original"
    t.geometry "the_geom", limit: {:srid=>4326, :type=>"geometry"}
    t.index ["project_type_id"], name: "index_projects_on_project_type_id"
  end

  create_table "provinces", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regexp_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "expresion"
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurant_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "street_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "streets", id: :serial, force: :cascade do |t|
    t.integer "start_number"
    t.integer "end_number"
    t.integer "count_intersections"
    t.float "meters_long_intersection"
    t.line "the_geom"
    t.string "name"
    t.integer "city_id"
    t.integer "street_type_id"
    t.integer "code"
    t.string "city_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "terms", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "role"
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "token"
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "verification_pois", id: :serial, force: :cascade do |t|
    t.integer "poi_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "analytics_dashboards", "charts"
  add_foreign_key "has_project_types", "users"
  add_foreign_key "project_fields", "project_types"
  add_foreign_key "project_types", "users"
  add_foreign_key "projects", "project_types"
end
