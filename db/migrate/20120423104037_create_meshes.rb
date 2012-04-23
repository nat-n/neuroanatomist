class CreateMeshes < ActiveRecord::Migration
  def change
    create_table :meshes do |t|

      t.timestamps
    end
  end
end
