class CreateRegionDefinitionsShapesTable < ActiveRecord::Migration
  def up
    create_table :region_definitions_shapes, :id => false do |t|
      t.integer :region_definition_id, :shape_id
    end
  end

  def down
    drop_table :region_definitions_shapes
  end
end