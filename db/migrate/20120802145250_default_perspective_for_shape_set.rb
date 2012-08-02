class DefaultPerspectiveForShapeSet < ActiveRecord::Migration
  def change
    remove_column :perspectives, :is_default
    add_column    :perspectives, :default_for_shape_set_id, :integer
  end
end
