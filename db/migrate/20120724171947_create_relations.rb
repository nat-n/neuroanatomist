class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.string :name
      t.string :description
      t.integer :subject_type_id
      t.integer :object_type_id
      
      t.timestamps
    end
  end
end
