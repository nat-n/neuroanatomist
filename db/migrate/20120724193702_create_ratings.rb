class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.float :value
      t.string :comment
      
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      
      t.timestamps
    end
  end
end
