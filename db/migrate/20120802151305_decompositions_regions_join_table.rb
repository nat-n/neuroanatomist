class DecompositionsRegionsJoinTable < ActiveRecord::Migration
  def change
    create_table :decompositions_regions, :id => false do |t|
      t.integer :decomposition_id, :region_id
    end
  end
end
