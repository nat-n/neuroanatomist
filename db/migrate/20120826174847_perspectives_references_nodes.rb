class PerspectivesReferencesNodes < ActiveRecord::Migration
  def change
    add_column :perspectives, :node_id, :integer
    add_index :perspectives, :node_id
  end
end
