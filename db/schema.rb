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

ActiveRecord::Schema.define(version: 20210118132100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

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
    t.text "sql_sentence"
    t.integer "order"
    t.string "order_sql"
    t.text "group_sql"
    t.boolean "children", default: false
    t.string "conditions_sql"
    t.string "kpi_type"
    t.string "sql_full"
    t.index ["analysis_type_id"], name: "index_analytics_dashboards_on_analysis_type_id"
    t.index ["chart_id"], name: "index_analytics_dashboards_on_chart_id"
    t.index ["project_type_id"], name: "index_analytics_dashboards_on_project_type_id"
  end

  create_table "charts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_type_id"
    t.jsonb "properties"
  end

  create_table "choice_list_items", force: :cascade do |t|
    t.string "name"
    t.bigint "choice_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nested_list_id"
    t.index ["choice_list_id"], name: "index_choice_list_items_on_choice_list_id"
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

  create_table "crono_jobs", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log"
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supplier_map", default: "osm"
    t.string "url"
    t.integer "role_id"
    t.text "logo"
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

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "stack", default: false
    t.decimal "tick_x_min"
    t.decimal "tick_x_max"
    t.decimal "tick_y_min"
    t.decimal "tick_y_max"
    t.decimal "step_x"
    t.decimal "substep_x"
    t.boolean "data_labelling", default: false
    t.integer "chart_id"
    t.decimal "scale", default: "1.0"
    t.boolean "legend_display", default: false
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
    t.boolean "left_y_axis"
    t.string "point_type"
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

  create_table "layers", force: :cascade do |t|
    t.string "name"
    t.string "layer"
    t.string "url"
    t.text "description"
    t.string "type_layer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "model_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "event_id"
    t.bigint "model_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_permissions_on_event_id"
    t.index ["model_type_id"], name: "index_permissions_on_model_type_id"
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "photo_children", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.bigint "project_data_child_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "row_active", default: true
    t.datetime "gwm_created_at"
    t.index ["project_data_child_id"], name: "index_photo_children_on_project_data_child_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "row_active", default: true
    t.datetime "gwm_created_at"
  end

  create_table "project_data_children", force: :cascade do |t|
    t.jsonb "properties"
    t.integer "project_id"
    t.integer "project_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.serial "update_sequence", null: false
    t.boolean "row_active", default: true
    t.boolean "current_season", default: true
    t.datetime "gwm_created_at"
    t.datetime "gwm_updated_at"
    t.boolean "row_enabled", default: true
    t.datetime "disabled_at"
    t.index ["user_id"], name: "index_project_data_children_on_user_id"
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
    t.string "choice_list_key"
    t.integer "choice_list_id"
    t.integer "field_type_id"
    t.boolean "hidden", default: false
    t.integer "sort"
    t.boolean "read_only", default: false
    t.boolean "popup", default: false
    t.string "calculated_field"
    t.string "roles_read"
    t.text "data_script"
    t.boolean "filter_field", default: false
    t.boolean "heatmap_field", default: false
    t.boolean "colored_points_field", default: false
    t.string "roles_edit"
    t.boolean "data_table", default: false
    t.index ["project_type_id"], name: "index_project_fields_on_project_type_id"
  end

  create_table "project_filters", force: :cascade do |t|
    t.jsonb "properties"
    t.bigint "user_id", null: false
    t.bigint "project_type_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "owner", default: false
    t.integer "cross_layer_filter_id"
    t.index ["project_type_id"], name: "index_project_filters_on_project_type_id"
    t.index ["user_id"], name: "index_project_filters_on_user_id"
  end

  create_table "project_statuses", force: :cascade do |t|
    t.string "name"
    t.bigint "project_type_id"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_type"
    t.integer "priority"
    t.string "timer"
    t.integer "inherit_project_type_id"
    t.integer "inherit_status_id"
    t.index ["project_type_id"], name: "index_project_statuses_on_project_type_id"
  end

  create_table "project_subfields", force: :cascade do |t|
    t.string "name"
    t.bigint "project_field_id"
    t.bigint "regexp_type_id"
    t.string "key"
    t.bigint "choice_list_id"
    t.bigint "field_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "required"
    t.boolean "hidden", default: false
    t.boolean "read_only", default: false
    t.boolean "popup", default: false
    t.string "calculated_field"
    t.string "roles_read"
    t.integer "sort"
    t.text "data_script"
    t.string "roles_edit"
    t.index ["choice_list_id"], name: "index_project_subfields_on_choice_list_id"
    t.index ["field_type_id"], name: "index_project_subfields_on_field_type_id"
    t.index ["project_field_id"], name: "index_project_subfields_on_project_field_id"
    t.index ["regexp_type_id"], name: "index_project_subfields_on_regexp_type_id"
  end

  create_table "project_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "directory_name"
    t.string "name_layer"
    t.boolean "enabled_as_layer"
    t.string "layer_color"
    t.string "add_rows"
    t.string "type_geometry"
    t.boolean "syncronization_data", default: true
    t.boolean "tracking", default: false
    t.text "cover"
    t.integer "geo_restriction", default: 0, null: false
    t.boolean "multiple_edition", default: false
    t.integer "level", default: 1
    t.string "enable_period", default: "Nunca"
    t.index ["user_id"], name: "index_project_types_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.jsonb "properties"
    t.integer "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.geometry "the_geom", limit: {:srid=>4326, :type=>"geometry"}
    t.jsonb "properties_original"
    t.bigint "project_status_id"
    t.datetime "status_update_at", default: "2020-06-18 16:04:25"
    t.bigint "user_id"
    t.serial "update_sequence", null: false
    t.boolean "row_active", default: true
    t.boolean "current_season", default: true
    t.datetime "gwm_created_at"
    t.datetime "gwm_updated_at"
    t.boolean "row_enabled", default: true
    t.datetime "disabled_at"
    t.index ["project_status_id"], name: "index_projects_on_project_status_id"
    t.index ["project_type_id"], name: "index_projects_on_project_type_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "regexp_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "expresion"
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_customers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "customer_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_user_customers_on_customer_id"
    t.index ["user_id"], name: "index_user_customers_on_user_id"
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
    t.string "authentication_token"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "active"
    t.bigint "role_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
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

  add_foreign_key "analytics_dashboards", "analysis_types"
  add_foreign_key "analytics_dashboards", "charts"
  add_foreign_key "analytics_dashboards", "project_types"
  add_foreign_key "has_project_types", "project_types"
  add_foreign_key "permissions", "roles"
  add_foreign_key "photo_children", "project_data_children"
  add_foreign_key "project_fields", "project_types"
  add_foreign_key "project_filters", "project_types"
  add_foreign_key "project_statuses", "project_types"
  add_foreign_key "projects", "project_statuses"
  add_foreign_key "projects", "project_types"
  add_foreign_key "users", "roles"
end
