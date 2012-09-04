class RemoveOldVersioningFromShapeSets < ActiveRecord::Migration
  def change
    remove_column :shape_sets, :version
    add_column :shape_sets, :deploy, :boolean
  end
end
