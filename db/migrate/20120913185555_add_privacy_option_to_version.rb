class AddPrivacyOptionToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :show_author, :boolean, :default => true
  end
end
