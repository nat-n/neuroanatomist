class AddContentsToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :contents, :string
  end
end
