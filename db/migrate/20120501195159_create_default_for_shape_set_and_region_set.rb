class CreateDefaultForShapeSetAndRegionSet < ActiveRecord::Migration
  def change
    add_column :shape_sets, :is_default, :boolean, :default => false
    remove_column :shape_sets, :is_default
  end
end