class ReplaceRegionSetWithPerspective < ActiveRecord::Migration
  def change
    add_column    :shape_sets, :default_perspective_id, :integer
    add_column    :perspectives, :default_for_shape_set_id, :integer
  end
end