class AddBoundingBoxAndCenterPointToShapeSets < ActiveRecord::Migration
  def change
    add_column :shape_sets, :bounding_box, :string
    add_column :shape_sets, :radius, :float
    add_column :shape_sets, :center_point, :string
  end
end
