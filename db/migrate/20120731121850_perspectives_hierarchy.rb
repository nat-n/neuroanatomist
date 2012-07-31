class PerspectivesHierarchy < ActiveRecord::Migration
  def up
    add_column :perspectives, :style_set_id, :integer
  end

  def down
    remove_column :perspectives, :style_set_id
  end
end
