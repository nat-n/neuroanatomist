class MeshesIndexShapeSet < ActiveRecord::Migration
  def change
    add_column  :meshes, :shape_set_id, :integer
    add_index   :meshes, :shape_set_id
  end
end
