class CreateShapes < ActiveRecord::Migration
  def change
    create_table :shapes do |t|
      t.integer :volume_value
      t.string  :label
      t.integer :shape_set_id
      t.timestamps
    end    
  end
end
