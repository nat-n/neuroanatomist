class FixTags < ActiveRecord::Migration
  def up
    add_column :tags, :node_id, :integer
    add_index :tags, :node_id
  end

  def down
    remove_index :tags, :node_id
    remove_column :tags, :node_id
  end
end
