class CreatePerspectives < ActiveRecord::Migration
  def change
    create_table :perspectives do |t|
      t.string :name
      t.string :description

      t.float :height
      t.float :angle
      t.float :distance
      
      t.integer :style_set_id
      
      t.timestamps
    end
  end
end
