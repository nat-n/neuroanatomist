class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.string :name
      t.string :description
      t.string :synonyms
      t.string :neurolex_category
      t.string :dbpedia_resource
      t.string :wikipedia_title
      
      t.integer :type_id
      t.integer :node_id

      t.timestamps
    end
    
    add_column :regions, :thing_id, :integer
  end
end
