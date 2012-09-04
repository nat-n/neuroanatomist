class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      
      t.string    :version_string
      t.string    :description
      t.integer   :user_id
      
      t.integer   :updated_id
      t.string    :updated_type
      
      t.boolean   :is_current, :default => true
      
      t.timestamps
    end
    add_index :versions, :version_string
    add_index :versions, :user_id
    add_index :versions, :updated_id
    add_index :versions, :updated_type
    add_index :versions, :is_current
  end
end
