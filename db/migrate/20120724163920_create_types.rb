class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.string :name
      t.string :description
      
      t.integer :supertype_id

      t.timestamps
    end
  end
end
