class FixTags < ActiveRecord::Migration
  def up
    remove_column :things, :tag_id
    add_column :tags, :node_id, :integer
    add_index :tags, :node_id
  end

  def down
    add_column :things, :tag_id, :integer
    remove_index :tags, :node_id
    remove_column :tags, :node_id
  end
end
