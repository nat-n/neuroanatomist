class CreateTagsResourcesJoinTable < ActiveRecord::Migration
  def up
    create_table :tags_resources, :id => false do |t|
      t.integer :tag_id, :resource_id
    end
  end
  def down
    drop_table :tags_resources
  end
end
