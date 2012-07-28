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

ActiveRecord::Schema.define(:version => 20120726171050) do

  create_table "bibliographies", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "dynamic"
    t.integer  "referencable_id"
    t.string   "referencable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bibliographies_resources", :id => false, :force => true do |t|
    t.integer "bibliography_id"
    t.integer "resource_id"
  end

  create_table "facts", :force => true do |t|
    t.integer  "relation_id"
    t.integer  "subject_id"
    t.integer  "object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meshes", :force => true do |t|
    t.string   "mesh_data_id"
    t.integer  "back_shape_id"
    t.integer  "front_shape_id"
    t.integer  "datasize"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.string   "introduction"
    t.integer  "thing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "perspectives", :force => true do |t|
    t.float    "height"
    t.float    "angle"
    t.float    "distance"
    t.integer  "region_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.float    "value"
    t.string   "comment"
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "region_definitions", :force => true do |t|
    t.integer  "region_id"
    t.integer  "shape_set_id"
    t.boolean  "orphaned"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "region_definitions_shapes", :id => false, :force => true do |t|
    t.integer "region_definition_id"
    t.integer "shape_id"
  end

  create_table "region_sets", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",  :default => false
  end

  create_table "region_sets_regions", :id => false, :force => true do |t|
    t.integer "region_set_id"
    t.integer "region_id"
  end

  create_table "region_styles", :force => true do |t|
    t.string   "colour"
    t.float    "transparency"
    t.boolean  "label"
    t.boolean  "orphaned"
    t.integer  "perspective_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thing_id"
  end

  create_table "relations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "subject_type_id"
    t.integer  "object_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_types", :force => true do |t|
    t.string   "name"
    t.string   "required_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_type_id"
  end

  create_table "resources_tags", :id => false, :force => true do |t|
    t.integer "resource_id"
    t.integer "tag_id"
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.integer  "topic_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shape_sets", :force => true do |t|
    t.string   "subject"
    t.string   "version"
    t.string   "change_log"
    t.string   "notes"
    t.integer  "mesh_count"
    t.integer  "shape_count"
    t.integer  "datasize"
    t.string   "data_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",            :default => false
    t.integer  "default_region_set_id"
  end

  create_table "shapes", :force => true do |t|
    t.integer  "volume_value"
    t.string   "label"
    t.integer  "shape_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "things", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "synonyms"
    t.string   "neurolex_category"
    t.string   "dbpedia_resource"
    t.string   "wikipedia_title"
    t.integer  "type_id"
    t.integer  "tag_id"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "supertype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
