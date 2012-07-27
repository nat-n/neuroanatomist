class CreateBibliographies < ActiveRecord::Migration
  def change
    create_table :bibliographies do |t|
      t.string  :name
      t.string  :description
      t.boolean :dynamic
      
      t.integer :referencable_id
      t.string  :referencable_type

      t.timestamps
    end
  end
end
