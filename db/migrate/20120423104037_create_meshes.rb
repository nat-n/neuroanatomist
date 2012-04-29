class CreateMeshes < ActiveRecord::Migration
  def change
    create_table :meshes do |t|
      t.string  :mesh_data_id
      t.integer :back_shape_id
      t.integer :front_shape_id
      t.integer :datasize
      t.timestamps
    end
  end
end
