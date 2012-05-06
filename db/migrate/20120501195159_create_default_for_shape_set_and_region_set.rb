class CreateDefaultForShapeSetAndRegionSet < ActiveRecord::Migration
  def up
    add_column :shape_sets, :is_default, :boolean, :default => false
    add_column :shape_sets, :default_region_set_id, :integer
  end

  def down
    remove_column :shape_sets, :is_default
    remove_column :shape_sets, :default_region_set_id
  end
end