class CreatePerspectives < ActiveRecord::Migration
  def change
    create_table :perspectives do |t|
      t.float :height
      t.float :angle
      t.float :distance
      
      t.integer :region_set_id
      
      t.timestamps
    end
  end
end
