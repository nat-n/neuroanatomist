class LotsOfIndexes < ActiveRecord::Migration
  def change
    
    add_index :meshes, :mesh_data_id
    add_index :meshes, :back_shape_id
    add_index :meshes, :front_shape_id
    
    add_index :shapes, :volume_value
    add_index :shapes, :label
    add_index :shapes, :shape_set_id
    
    add_index :shape_sets, :subject
    add_index :shape_sets, :version
    
    add_index :regions, :name
    add_index :regions, :thing_id
    
    add_index :region_definitions, :region_id
    add_index :region_definitions, :shape_set_id
    
    add_index :types, :name, :unique => true
    add_index :types, :supertype_id
    
    add_index :tags, :name, :unique => true
    
    add_index :things, :name, :unique => true
    add_index :things, :type_id
    add_index :things, :node_id
    
    add_index :relations, :name, :unique => true
    add_index :relations, :subject_type_id
    add_index :relations, :object_type_id

    add_index :facts, :relation_id
    add_index :facts, :subject_id
    add_index :facts, :object_id
    
    add_index :perspectives, :name
    add_index :perspectives, :style_set_id

    add_index :region_styles, :perspective_id
    add_index :region_styles, :region_id
    
    add_index :resources, :resource_type_id
    
    add_index :bibliographies, :name
    add_index :bibliographies, :referencable_id
    
    add_index :ratings, :tag_id
    add_index :ratings, :taggable_id
    add_index :ratings, :value

    add_index :sections, :name
    add_index :sections, :topic_id
    add_index :sections, :article_id
    
    
    add_index :nodes, :name, :unique => true
    add_index :nodes, :thing_id

    add_index :resource_types, :name

    add_index :decompositions, :region_id
    
  end
end
