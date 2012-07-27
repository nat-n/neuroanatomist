class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :introduction
      
      t.integer :thing_id
      
      t.timestamps
    end
  end
end
