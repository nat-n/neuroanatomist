class CreateResourcesTagsJoinTable < ActiveRecord::Migration
  def up
    create_table :resources_tags, :id => false do |t|
      t.integer :resource_id, :tag_id
    end
  end
  def down
    drop_table :resources_tags
  end
end
