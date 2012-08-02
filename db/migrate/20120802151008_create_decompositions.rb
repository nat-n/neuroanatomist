class CreateDecompositions < ActiveRecord::Migration
  def change
    create_table :decompositions do |t|
      t.string :description
      t.integer :rank
      
      t.integer :region_id
      
      t.timestamps
    end
  end
end
