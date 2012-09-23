class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :name
      t.string  :description
      t.integer :node_id, :integer
      
      t.timestamps
    end
    
    add_index :tags, :node_id
  end
end
