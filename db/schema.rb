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

ActiveRecord::Schema.define(:version => 20120915183522) do

  create_table "bibliographies", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "dynamic"
    t.integer  "referencable_id"
    t.string   "referencable_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "bibliographies", ["name"], :name => "index_bibliographies_on_name"
  add_index "bibliographies", ["referencable_id"], :name => "index_bibliographies_on_referencable_id"

  create_table "bibliographies_resources", :id => false, :force => true do |t|
    t.integer "bibliography_id"
    t.integer "resource_id"
  end

  create_table "decompositions", :force => true do |t|
    t.string   "description"
    t.integer  "rank"
    t.integer  "region_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "decompositions", ["region_id"], :name => "index_decompositions_on_region_id"

  create_table "decompositions_regions", :id => false, :force => true do |t|
    t.integer "decomposition_id"
    t.integer "region_id"
  end

  create_table "facts", :force => true do |t|
    t.integer  "relation_id"
    t.integer  "subject_id"
    t.integer  "object_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "facts", ["object_id"], :name => "index_facts_on_object_id"
  add_index "facts", ["relation_id"], :name => "index_facts_on_relation_id"
  add_index "facts", ["subject_id"], :name => "index_facts_on_subject_id"

  create_table "jax_data", :force => true do |t|
    t.string   "request_string"
    t.string   "response_description"
    t.string   "cache_id"
    t.string   "destroy_key"
    t.integer  "shape_set_id"
    t.string   "perspectives"
    t.integer  "count",                :default => 0
    t.boolean  "expired",              :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "regions"
  end

  add_index "jax_data", ["request_string"], :name => "index_jax_data_on_request_string", :unique => true
  add_index "jax_data", ["shape_set_id"], :name => "index_jax_data_on_shape_set_id"

  create_table "meshes", :force => true do |t|
    t.string   "mesh_data_id"
    t.integer  "back_shape_id"
    t.integer  "front_shape_id"
    t.integer  "datasize"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "shape_set_id"
  end

  add_index "meshes", ["back_shape_id"], :name => "index_meshes_on_back_shape_id"
  add_index "meshes", ["front_shape_id"], :name => "index_meshes_on_front_shape_id"
  add_index "meshes", ["mesh_data_id"], :name => "index_meshes_on_mesh_data_id"
  add_index "meshes", ["shape_set_id"], :name => "index_meshes_on_shape_set_id"

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.string   "introduction"
    t.integer  "thing_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "is_default",   :default => false
  end

  add_index "nodes", ["name"], :name => "index_nodes_on_name", :unique => true
  add_index "nodes", ["thing_id"], :name => "index_nodes_on_thing_id"

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "permitted_id"
    t.string   "permitted_type"
    t.string   "action"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "perspectives", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.float    "height"
    t.float    "angle"
    t.float    "distance"
    t.integer  "style_set_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "default_for_shape_set_id"
    t.integer  "node_id"
  end

  add_index "perspectives", ["name"], :name => "index_perspectives_on_name"
  add_index "perspectives", ["node_id"], :name => "index_perspectives_on_node_id"
  add_index "perspectives", ["style_set_id"], :name => "index_perspectives_on_style_set_id"

  create_table "quizzes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ratings", :force => true do |t|
    t.float    "value"
    t.string   "comment"
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ratings", ["tag_id"], :name => "index_ratings_on_tag_id"
  add_index "ratings", ["taggable_id"], :name => "index_ratings_on_taggable_id"
  add_index "ratings", ["value"], :name => "index_ratings_on_value"

  create_table "region_definitions", :force => true do |t|
    t.integer  "region_id"
    t.integer  "shape_set_id"
    t.boolean  "orphaned",     :default => false
    t.string   "notes"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "region_definitions", ["region_id"], :name => "index_region_definitions_on_region_id"
  add_index "region_definitions", ["shape_set_id"], :name => "index_region_definitions_on_shape_set_id"

  create_table "region_definitions_shapes", :id => false, :force => true do |t|
    t.integer "region_definition_id"
    t.integer "shape_id"
  end

  create_table "region_styles", :force => true do |t|
    t.string   "colour"
    t.float    "transparency"
    t.boolean  "label"
    t.boolean  "orphaned"
    t.integer  "perspective_id"
    t.integer  "region_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "region_styles", ["perspective_id"], :name => "index_region_styles_on_perspective_id"
  add_index "region_styles", ["region_id"], :name => "index_region_styles_on_region_id"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "thing_id"
    t.string   "label"
    t.integer  "default_perspective_id"
  end

  add_index "regions", ["default_perspective_id"], :name => "index_regions_on_default_perspective_id"
  add_index "regions", ["name"], :name => "index_regions_on_name"
  add_index "regions", ["thing_id"], :name => "index_regions_on_thing_id"

  create_table "relations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "subject_type_id"
    t.integer  "object_type_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "relations", ["name"], :name => "index_relations_on_name", :unique => true
  add_index "relations", ["object_type_id"], :name => "index_relations_on_object_type_id"
  add_index "relations", ["subject_type_id"], :name => "index_relations_on_subject_type_id"

  create_table "resource_types", :force => true do |t|
    t.string   "name"
    t.string   "required_fields"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "resource_types", ["name"], :name => "index_resource_types_on_name"

  create_table "resources", :force => true do |t|
    t.string   "title"
    t.string   "authors"
    t.string   "journal"
    t.string   "publication_date"
    t.string   "volume"
    t.string   "issue"
    t.string   "pages"
    t.string   "doi"
    t.string   "url"
    t.string   "abstract"
    t.string   "description"
    t.integer  "resource_type_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "resources", ["resource_type_id"], :name => "index_resources_on_resource_type_id"

  create_table "resources_tags", :id => false, :force => true do |t|
    t.integer "resource_id"
    t.integer "tag_id"
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.integer  "topic_id"
    t.integer  "article_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sections", ["article_id"], :name => "index_sections_on_article_id"
  add_index "sections", ["name"], :name => "index_sections_on_name"
  add_index "sections", ["topic_id"], :name => "index_sections_on_topic_id"

  create_table "shape_sets", :force => true do |t|
    t.string   "subject"
    t.string   "change_log"
    t.string   "notes"
    t.integer  "mesh_count"
    t.integer  "shape_count"
    t.integer  "datasize"
    t.string   "data_created_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_default",             :default => false
    t.integer  "default_perspective_id"
    t.string   "bounding_box"
    t.float    "radius"
    t.string   "center_point"
    t.boolean  "deploy"
    t.boolean  "expired",                :default => false
  end

  add_index "shape_sets", ["subject"], :name => "index_shape_sets_on_subject"

  create_table "shapes", :force => true do |t|
    t.integer  "volume_value"
    t.string   "label"
    t.integer  "shape_set_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "shapes", ["label"], :name => "index_shapes_on_label"
  add_index "shapes", ["shape_set_id"], :name => "index_shapes_on_shape_set_id"
  add_index "shapes", ["volume_value"], :name => "index_shapes_on_volume_value"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "node_id"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["node_id"], :name => "index_tags_on_node_id"

  create_table "things", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "synonyms"
    t.string   "neurolex_category"
    t.string   "dbpedia_resource"
    t.string   "wikipedia_title"
    t.integer  "type_id"
    t.integer  "node_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "scholarpedia_article"
  end

  add_index "things", ["name"], :name => "index_things_on_name", :unique => true
  add_index "things", ["node_id"], :name => "index_things_on_node_id"
  add_index "things", ["type_id"], :name => "index_things_on_type_id"

  create_table "types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "supertype_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "types", ["name"], :name => "index_types_on_name", :unique => true
  add_index "types", ["supertype_id"], :name => "index_types_on_supertype_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",     :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",     :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "alias"
    t.string   "name"
    t.boolean  "admin",                                 :default => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "data_count",                            :default => 0
    t.string   "group",                                 :default => "none"
  end

  add_index "users", ["alias"], :name => "index_users_on_alias", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "v_caches", :force => true do |t|
    t.string   "request_string"
    t.string   "cache_id"
    t.string   "destroy_key"
    t.string   "type"
    t.string   "ids"
    t.integer  "count",          :default => 0
    t.boolean  "expired",        :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "v_caches", ["cache_id"], :name => "index_v_caches_on_cache_id"
  add_index "v_caches", ["request_string"], :name => "index_v_caches_on_request_string"

  create_table "versions", :force => true do |t|
    t.string   "version_string"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "updated_id"
    t.string   "updated_type"
    t.boolean  "is_current",     :default => true
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "contents"
    t.boolean  "show_author",    :default => true
  end

  add_index "versions", ["is_current"], :name => "index_versions_on_is_current"
  add_index "versions", ["updated_id"], :name => "index_versions_on_updated_id"
  add_index "versions", ["updated_type"], :name => "index_versions_on_updated_type"
  add_index "versions", ["user_id"], :name => "index_versions_on_user_id"
  add_index "versions", ["version_string"], :name => "index_versions_on_version_string"

end
