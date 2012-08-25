class CreateShapeSets < ActiveRecord::Migration
  def change
    create_table :shape_sets do |t|
      t.string  :subject
      t.string  :version
      t.string  :change_log
      t.string  :notes
      t.integer :mesh_count
      t.integer :shape_count
      t.integer :datasize
      t.string  :data_created_at
      
      t.string  :bounding_box
      t.string  :center_point
      t.float   :radius
      
      t.timestamps
    end    
  end
end
